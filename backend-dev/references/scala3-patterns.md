# Scala 3 Backend Patterns

Reference guide for backend-dev when working on Scala 3 projects.

## Project Structure (DDD-aligned)

```
src/main/scala/com/company/context/
├── domain/
│   ├── model/
│   │   ├── Order.scala         # Aggregate root
│   │   ├── OrderItem.scala     # Entity / Value Object
│   │   ├── OrderStatus.scala   # ADT (enum)
│   │   └── package.scala       # Opaque types (OrderId, CustomerId, etc.)
│   ├── events/
│   │   └── OrderEvents.scala   # Domain events (sealed trait / enum)
│   ├── errors/
│   │   └── OrderError.scala    # Domain error ADT
│   └── repository/
│       └── OrderRepository.scala # Pure trait, no implementation
├── application/
│   └── order/
│       ├── CreateOrderUseCase.scala
│       └── ConfirmOrderUseCase.scala
├── infrastructure/
│   ├── persistence/
│   │   └── PostgresOrderRepository.scala
│   ├── messaging/
│   │   └── KafkaEventPublisher.scala
│   └── http/
│       └── OrderRoutes.scala
└── Main.scala
```

## Opaque Types (Value Objects)

```scala
// domain/model/package.scala
package com.company.ordering.domain.model

import java.util.UUID

// ✅ Opaque types — no runtime overhead, full type safety
opaque type OrderId = UUID
object OrderId:
  def apply(uuid: UUID): OrderId = uuid
  def generate(): OrderId = UUID.randomUUID()
  extension (id: OrderId) def value: UUID = id

opaque type CustomerId = UUID
object CustomerId:
  def apply(uuid: UUID): CustomerId = uuid
  extension (id: CustomerId) def value: UUID = id

// ✅ Self-validating value object
opaque type Email = String
object Email:
  def from(s: String): Either[ValidationError, Email] =
    Either.cond(
      s.contains("@") && s.length > 3,
      s,
      ValidationError.InvalidEmail(s)
    )
  extension (e: Email) def value: String = e
```

## ADTs with Scala 3 Enums

```scala
// ✅ Status ADT
enum OrderStatus:
  case Draft
  case Confirmed
  case Shipped(trackingNumber: TrackingNumber)
  case Cancelled(reason: CancellationReason)

// ✅ Domain errors
enum OrderError:
  case EmptyOrder
  case AlreadyConfirmed
  case ItemNotAvailable(itemId: ItemId)
  case InvalidStatusTransition(from: OrderStatus, to: String)

// ✅ Domain events — immutable facts, past tense
sealed trait OrderEvent:
  def orderId: OrderId
  def occurredAt: java.time.Instant

object OrderEvent:
  final case class OrderPlaced(
    orderId: OrderId,
    customerId: CustomerId,
    items: List[OrderItem],
    occurredAt: java.time.Instant
  ) extends OrderEvent

  final case class OrderConfirmed(
    orderId: OrderId,
    occurredAt: java.time.Instant
  ) extends OrderEvent
```

## Aggregate Root

```scala
// ✅ Aggregate — all mutations return Either[Error, NewState]
final case class Order private (
  id: OrderId,
  customerId: CustomerId,
  items: List[OrderItem],
  status: OrderStatus
):
  def addItem(item: OrderItem): Either[OrderError, Order] =
    status match
      case OrderStatus.Draft => Right(copy(items = items :+ item))
      case other => Left(OrderError.InvalidStatusTransition(other, "addItem"))

  def confirm(): Either[OrderError, (Order, OrderEvent.OrderConfirmed)] =
    status match
      case OrderStatus.Draft if items.nonEmpty =>
        val confirmed = copy(status = OrderStatus.Confirmed)
        val event = OrderEvent.OrderConfirmed(id, java.time.Instant.now())
        Right((confirmed, event))
      case OrderStatus.Draft => Left(OrderError.EmptyOrder)
      case other => Left(OrderError.InvalidStatusTransition(other, "confirm"))

object Order:
  def create(id: OrderId, customerId: CustomerId): (Order, OrderEvent.OrderPlaced) =
    val order = Order(id, customerId, Nil, OrderStatus.Draft)
    val event = OrderEvent.OrderPlaced(id, customerId, Nil, java.time.Instant.now())
    (order, event)
```

## Repository Pattern

```scala
// ✅ Domain owns the interface — no F[_] leakage from infrastructure
trait OrderRepository[F[_]]:
  def findById(id: OrderId): F[Option[Order]]
  def save(order: Order): F[Unit]
  def findByCustomer(customerId: CustomerId): F[List[Order]]

// ✅ In-memory for tests (pure)
import cats.effect.{IO, Ref}

class InMemoryOrderRepository(ref: Ref[IO, Map[OrderId, Order]]) extends OrderRepository[IO]:
  def findById(id: OrderId): IO[Option[Order]] =
    ref.get.map(_.get(id))

  def save(order: Order): IO[Unit] =
    ref.update(_.updated(order.id, order))

  def findByCustomer(customerId: CustomerId): IO[List[Order]] =
    ref.get.map(_.values.filter(_.customerId == customerId).toList)

object InMemoryOrderRepository:
  def make(): IO[InMemoryOrderRepository] =
    Ref.of[IO, Map[OrderId, Order]](Map.empty).map(new InMemoryOrderRepository(_))
```

## Application Services (Use Cases)

```scala
// ✅ Thin — orchestrates domain, no business logic
class ConfirmOrderUseCase[F[_]: MonadThrow](
  repo: OrderRepository[F],
  publisher: EventPublisher[F]
):
  def execute(id: OrderId): F[Unit] =
    for
      orderOpt <- repo.findById(id)
      order    <- orderOpt.liftTo[F](OrderNotFound(id))
      result   <- order.confirm().liftTo[F]
      (confirmed, event) = result
      _        <- repo.save(confirmed)
      _        <- publisher.publish(event)
    yield ()
```

## Effect System Patterns

```scala
// ✅ ZIO style
import zio.*

def confirmOrder(id: OrderId): ZIO[OrderRepository & EventPublisher, OrderError | RepoError, Unit] =
  for
    orderOpt <- ZIO.serviceWithZIO[OrderRepository](_.findById(id))
    order    <- ZIO.fromOption(orderOpt).orElseFail(OrderError.NotFound(id))
    result   <- ZIO.fromEither(order.confirm())
    (confirmed, event) = result
    _        <- ZIO.serviceWithZIO[OrderRepository](_.save(confirmed))
    _        <- ZIO.serviceWithZIO[EventPublisher](_.publish(event))
  yield ()

// ✅ Cats Effect / IO style — see application service above
```

## Testing with MUnit (Scala 3 preferred)

```scala
import munit.CatsEffectSuite

class OrderSpec extends CatsEffectSuite:

  // ✅ Pure domain test — synchronous
  test("order cannot be confirmed when empty"):
    val (order, _) = Order.create(OrderId.generate(), CustomerId.generate())
    val result = order.confirm()
    assertEquals(result, Left(OrderError.EmptyOrder))

  test("order can be confirmed with items"):
    val (order, _) = Order.create(OrderId.generate(), CustomerId.generate())
    val item = OrderItem(ItemId.generate(), Quantity(1), Money(10, Currency.SAR))
    val withItem = order.addItem(item).getOrElse(fail("addItem failed"))
    val result = withItem.confirm()
    assert(result.isRight)
    assertEquals(result.map(_._1.status), Right(OrderStatus.Confirmed))

  // ✅ Application test with in-memory repo
  test("confirm order persists and publishes event"):
    for
      repo      <- InMemoryOrderRepository.make()
      publisher <- InMemoryEventPublisher.make()
      useCase   =  ConfirmOrderUseCase(repo, publisher)
      (order, _) = Order.create(OrderId.generate(), CustomerId.generate())
      item      =  OrderItem(ItemId.generate(), Quantity(1), Money(10, Currency.SAR))
      withItem  <- IO.fromEither(order.addItem(item))
      _         <- repo.save(withItem)
      _         <- useCase.execute(withItem.id)
      saved     <- repo.findById(withItem.id)
      events    <- publisher.published
    yield
      assertEquals(saved.map(_.status), Some(OrderStatus.Confirmed))
      assertEquals(events.size, 1)
```

## Common Anti-Patterns to Reject

```scala
// ❌ Mutable state in domain
class OrderService:
  private var orders: mutable.Map[OrderId, Order] = mutable.Map.empty  // NO

// ❌ Business logic in controller
def confirmOrder(id: String): Future[Result] =
  val order = db.find(id)
  if order.items.isEmpty then Future.successful(BadRequest("no items"))  // NO — domain logic here
  else ...

// ❌ Infrastructure type in domain
import slick.jdbc.PostgresProfile.api._
case class Order(id: OrderId, row: Orders#TableElementType)  // NO — Slick in domain

// ❌ Stringly typed
case class Order(status: String)  // NO — use enum

// ❌ Null / throwing in domain
def findItem(id: ItemId): OrderItem = items.find(_.id == id).get  // NO — throws

// ✅ Correct versions of all the above are in the patterns above
```
