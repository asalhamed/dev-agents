# IoT Sales Objection Handling

## Framework: Acknowledge → Explore → Respond → Confirm

### "We're concerned about data security"
- **Acknowledge:** "Security is critical, especially with operational data."
- **Explore:** "What's your security team's biggest concern — data in transit, at rest, or access control?"
- **Respond:** "We use end-to-end encryption (TLS 1.3), SOC2 Type II certified, and we offer on-premises deployment if your data can't leave your network."
- **Confirm:** "Would a call between your security team and our CISO address the remaining concerns?"

### "We don't want vendor lock-in"
- **Acknowledge:** "Smart concern. Lock-in is a real risk in IoT."
- **Respond:** "Our devices use standard MQTT (not proprietary protocols). Data is always exportable. We support ONVIF cameras (not just specific brands). If you ever leave, your data and devices still work."

### "We can't justify the ROI"
- **Explore:** "Let's build the business case together. How many field visits per month? Average cost per visit?"
- **Respond:** Use ROI calculator with their numbers. Focus on: field visit reduction, faster incident response, insurance premium reduction, avoided incidents.
- **Confirm:** "Based on your numbers, payback is [X months]. Want to validate with a pilot?"

### "Integration with our existing SCADA/BMS/VMS is too complex"
- **Respond:** "We coexist with SCADA — we don't replace it. We add remote monitoring, video, and analytics on top. Integration is API-based (Modbus, OPC-UA, REST). We've done this at [reference customer]."

### "The reliability/uptime SLA isn't enough"
- **Explore:** "What uptime do you need? What's the cost of an hour of downtime for you?"
- **Respond:** "Our SLA is 99.9%. For critical sites, we offer on-premises edge processing — works even if internet goes down. Let's discuss what SLA matches your requirements."

### "We tried IoT before and it failed"
- **Explore:** "What happened? Was it connectivity, reliability, or lack of business value?"
- **Respond:** "That's why we do a 30-day pilot first. You see results with your own data before committing. And we've solved the common failure modes: offline-first architecture, cellular backup, automated alerting."
