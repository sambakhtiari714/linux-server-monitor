# Linux Server Monitor

A modular Bash-based monitoring and incident-analysis tool for Linux servers.
It doesn't just print resource usage — it watches services, pulls their logs
on failure, classifies the failure pattern, and scores it into a severity
level (`LOW` → `CRITICAL`), similar in spirit to how alerting rules work in
tools like Prometheus Alertmanager or Datadog Monitors.

## What it actually does

**System health checks**
- Hostname, current user, uptime
- Disk usage (`df`), RAM usage (`free`), CPU usage (`top` + load average)
- Each metric is evaluated against configurable warning/critical thresholds

**Service monitoring**
- Checks `ssh`, `nginx`, `docker` via `systemctl is-active`

**Incident pipeline (triggered only when a service is down)**
1. **Log Engine** — pulls the last 30 lines of the service's journal
   (`journalctl -u <service>`), handling edge cases: service not installed,
   no log entries, permission denied
2. **Pattern Engine** — scans the logs for `error`, `warning`, `failed`,
   `timeout`, `panic`, `permission denied`, `connection refused` and counts
   each category
3. **Severity Engine** — turns those counts into a weighted incident score
   (timeouts weighted heaviest, then errors, then failures, then warnings)
   and maps the score to `LOW` / `MEDIUM` / `HIGH` / `CRITICAL`
4. **Incident Builder / Report Engine** — assembles everything into a
   structured incident report printed to the terminal and appended to
   `logs/system.log`

**Exit codes**
- Exits `0` if everything is healthy, `1` if any service is down — so it
  can be used directly in cron jobs, systemd timers, or CI health checks.

## Architecture

```
monitor.sh
  ├── collectors/   → disk.sh, ram.sh, cpu.sh, services.sh
  └── engine/
        ├── policy_engine.sh     (thresholds → OK/WARNING/CRITICAL)
        ├── log_engine.sh        (journalctl wrapper + edge cases)
        ├── pattern_engine.sh    (log line classification)
        ├── severity_engine.sh   (score → severity level)
        ├── incident_builder.sh  (assembles incident object)
        └── report_engine.sh     (terminal + log output)
```

## Usage

```bash
chmod +x monitor.sh
./monitor.sh
echo "exit code: $?"
```

Thresholds and the monitored service list live in `config/config.conf`:

```bash
DISK_WARNING_THRESHOLD=80
DISK_CRITICAL_THRESHOLD=90
RAM_WARNING_THRESHOLD=80
RAM_CRITICAL_THRESHOLD=90
CPU_WARNING_THRESHOLD=80
CPU_CRITICAL_THRESHOLD=90
SERVICES="ssh nginx docker"
```

## Sample incident output

```
========= INCIDENT =======
Component      : nginx
Status         : DOWN
Pattern State  : ERROR
Incident Score : 14
Severity       : HIGH
Log Level      : ERROR
Error Count    : 3
Warning Count  : 1
Failed Count   : 2
Timeout Count  : 0

Detected Issues:
----------------
Jul 09 10:44:01 nginx[1]: bind() to 0.0.0.0:80 failed (98: Address already in use)
```

## Technologies Used

Bash, Linux, `awk`, `sed`, `systemctl`, `journalctl`, `tee`

## Roadmap (not implemented yet)

The next phase is a Python/FastAPI service that reads a structured
`incidents.json` export from this pipeline, sends each incident to an LLM
(via OpenRouter) for root-cause analysis and fix suggestions, and returns
a structured JSON response rendered as CLI output / Markdown report / REST
API. This is planned but **not built yet** — the current repo only covers
detection, log analysis, and severity scoring on the Bash side.

## Known limitations

- Currently checks a fixed service list (`ssh`, `nginx`, `docker`) in code;
  the `SERVICES` value in `config.conf` is used by the incident loop but not
  yet by the service checker itself.
- No automated tests yet (planned: `bats` for the Bash layer).
- No JSON export yet — output is human-readable text/log only.

## Author

Sam
