# Infrastructure dimensions for cloud system engineer

Complementary to the 8 architecture dimensions, the cloud system engineer checks these
infrastructure-specific aspects:

## 1. Compute & resources
**Check when:** new agent, new daemon, new container, higher load expected.
- CPU headroom: enough reserve for peak times?
- RAM: Node.js heap + Docker overhead + OS. Swap configured?
- Disk I/O: SQLite WAL mode at high write load? Log rotation active?
- Process limits: ulimit, max file descriptors, max processes

## 2. Containers & orchestration
**Check when:** new service, Docker change, volume change.
- Container health: restart policy (always/unless-stopped)?
- Volume persistence: critical data on named volumes, not in container?
- Networking: container-to-container communication (Docker network)?
- Image updates: how are containers updated? Downtime?
- Resource limits: Docker memory/CPU limits set?

## 3. Network & connectivity
**Check when:** new external service, new port, new API connection.
- Firewall: only required ports open (principle of least privilege)
- Egress: which external APIs must be reachable?
- Ingress: which ports are externally reachable? Why?
- Latency: is the hosting location optimal for the APIs?
- Bandwidth: enough for WebSocket streams + API calls?

## 4. Security & hardening
**Check when:** always. On every review.
- SSH: key-only auth? Non-standard port? Fail2Ban active?
- Firewall: UFW/iptables correct? Default-deny policy?
- Updates: OS patches current? Node.js LTS?
- Secrets: .env protected on VPS (chmod 600)? Not in Git?
- Docker: containers run as non-root? Read-only filesystem where possible?
- TLS: certificates for all exposed endpoints?

## 5. Backup & disaster recovery
**Check when:** new critical data, new database, new configuration.
- VPS backup: auto-backup active? Interval?
- Data backup: trades journal, database, .env — how is it secured?
- Recovery time: how quickly can the system be restored?
- Rollback plan: on failed update — how to go back?

## 6. Monitoring & alerting
**Check when:** new critical path, new daemon, new external dependency.
- Uptime monitoring: active?
- Disk-space alert: warning before disk is full?
- Container health: auto-restart on crash?
- API health: externally reachable endpoints monitored?

## 7. Cost & scaling
**Check when:** resource increase needed, new service, upgrade planning.
- VPS plan: does the current plan suffice? Next tier needed?
- Bandwidth cost: observe traffic limit of the plan
- Scaling path: vertical (bigger VPS) vs. horizontal (multiple VPS)
- Alternative hosting options for specific workloads
