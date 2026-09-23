# Windows online deployment v4.9.0

- Base: hsd0615/sgqz master, commit 6563f8d657966038d09267e7a2a0d597c5faaa59.
- ECS: i-bp1e0xihm2iomvnexnld, cn-hangzhou, public IP 47.114.59.65.
- Runtime: Windows Server 2022, Node.js 22.12.0, uuid 9.0.1.
- Server: C:\opt\start_fixed.js; client files: C:\opt\client.
- Player data: C:\opt\data\sanguo.json; logs: C:\opt\server.log.
- Scheduled task: sgqz-online-4.9.0, SYSTEM, at startup, automatic restart after failure.
- Startup command: tools/start-server-windows.cmd, deployed as C:\opt\start-server.cmd.
- Public TCP ports: 3000 (HTTP API/assets) and 3001 (game protocol).
- The existing C:\sgqz\server service on 8080/8088 and its data were preserved.
- This new online database was initialized by the upstream server. Old server player saves were not migrated.
- Remote HTTP administration requires SGQZ_ADMIN_KEY; no key is configured by default. Use ECS Cloud Assistant for maintenance.

Validation: compiled ActionScript; checked Node syntax; verified public health/version, XML downloads, login and TCP auth; matched downloaded main.swf SHA256 and embedded 4.9.0/new IP; matched general.swf SHA256; tested task restart; generated general stats HTML.

main.swf SHA256: 06777fdb7ff7a22d0db3bf9528a1b25e72ce16ef254104127c358ba73096be1b

No full interactive battle was played during deployment verification. The Linux-specific cloud-deploy.js is not applicable to this Windows instance.
