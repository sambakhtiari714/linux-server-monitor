# Linux Server Monitor

A two-part Linux server monitoring and incident-analysis tool.

The **Bash side** watches system resources and services, pulls logs on
failure, classifies the failure pattern, and scores it into a severity
level (`OK` → `CRITICAL`) — similar in spirit to how alerting rules work
in tools like Prometheus Alertmanager or Datadog Monitors. It writes a
structured `incidents.json` report.

The **Python side** (FastAPI + an LLM via OpenRouter) reads that report
and produces root-cause analysis and fix suggestions for anything
serious, plus a short status note for everything else.

## Architecture

```
Bash                                   Python
----                                   ------
monitor.sh
  ├── collectors/  disk, ram, cpu, services
  └── engine/
        ├── config_validator.sh   (fail fast on bad config)
        ├── policy_engine.sh      (thresholds → status/severity)
        ├── log_engine.sh         (journalctl wrapper + edge cases)
        ├── pattern_engine.sh     (log classification + critical-pattern detection)
        ├── severity_engine.sh    (score + pattern → final severity)
        ├── incident_builder.sh   (assembles the incident object)
        ├── json_engine.sh        (writes output/incidents.json)
        └── report_engine.sh      (terminal output)
        │
        ▼
  output/incidents.json  ───────────►  python/models.py        (Pydantic contract)
                                       python/validate_incidents.py
                                       api/main.py              (FastAPI: POST /analyze)
                                       llm/prompt_builder.py    (severity-aware prompt)
                                       llm/openrouter_client.py (LLM call, retries)
```

The exact shape of `incidents.json` is frozen in
[`docs/incidents.schema.json`](docs/incidents.schema.json), with a worked
example in [`docs/incidents.example.json`](docs/incidents.example.json).
Both the Bash side and the Python side are built against that same
contract, so either side can be changed independently as long as the
contract itself doesn't change.

## Part 1 — Bash: detection and scoring

**System health checks**
- Hostname, current user, uptime
- Disk (`df`), RAM (`free`), CPU (`top` + load average) usage, each
  checked against configurable warning/critical thresholds

**Service monitoring**
- Checks every service listed in `config/config.conf` (`SERVICES=...`)
  via `systemctl is-active`

**Incident pipeline (for any service that's down)**
1. **Log Engine** — pulls the last lines of the service's journal
   (`journalctl -u <service>`), handling edge cases: not installed,
   no log entries, permission denied
2. **Pattern Engine** — counts `error` / `warning` / `failed` / `timeout`
   lines, and separately flags catastrophic patterns (`kernel panic`,
   `out of memory`, `segmentation fault`, `filesystem corruption`)
3. **Severity Engine** — turns the counts into a score, unless a
   catastrophic pattern was found, in which case severity is forced to
   `CRITICAL` regardless of score
4. **JSON Engine** — every service (healthy or not) and every system
   metric is written into `output/incidents.json`, following the frozen
   schema

**Exit codes:** `0` if everything is healthy, `1` if any service is
down, `2` if `config.conf` itself is invalid — so it plugs directly into
cron, systemd timers, or CI health checks.

### Usage

```bash
sudo apt install -y jq        # required for JSON generation
chmod +x monitor.sh
./monitor.sh
echo "exit code: $?"
cat output/incidents.json
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

`config_validator.sh` checks this file before anything else runs, and
aborts with a clear error (exit code `2`) if a threshold isn't numeric,
a warning threshold isn't below its critical threshold, or `SERVICES`
is empty.

## Part 2 — Python: analysis via LLM

**Validate the contract independently, without starting any server:**
```bash
pip install -r python/requirements.txt
python3 python/validate_incidents.py output/incidents.json
```

**Run the API:**
```bash
export OPENROUTER_API_KEY="sk-or-...."   # never commit this
cd api
python3 -m uvicorn main:app --reload
```

**Call it:**
```bash
curl -X POST http://127.0.0.1:8000/analyze \
  -H "Content-Type: application/json" \
  -d @../output/incidents.json
```

Internally, `POST /analyze`:
1. Validates the incoming JSON against the same `IncidentReport`
   Pydantic model used by `validate_incidents.py`
2. Builds a prompt (`llm/prompt_builder.py`) that asks for a full
   root-cause analysis for anything `HIGH`/`CRITICAL`, and only a
   one-line status (plus a suggestion, if one is actually warranted)
   for everything else
3. Sends it to an LLM through OpenRouter (`llm/openrouter_client.py`),
   with retries and clear errors on failure

FastAPI also gives you a free interactive test page at
`http://127.0.0.1:8000/docs` once the server is running.

## Sample incident (Bash terminal output)

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

## Technologies used

Bash, `jq`, `systemctl`, `journalctl`, Python, Pydantic, FastAPI,
Uvicorn, OpenRouter

## Roadmap

- Turn the LLM's free-text answer into a structured, validated response
  (`DetailedFinding` / `BriefNote`) instead of raw text
- CLI and Markdown report generation from that structured response
- Dockerfile / docker-compose for the whole pipeline
- Automated tests (`bats` for Bash, `pytest` for Python) and CI
- **Stretch goals (post-v1.0, not committed to yet):** history database,
  web dashboard, notifications

## Known limitations

- No automated tests yet
- The LLM's response is currently unstructured free text (see Roadmap)
- Single-host only; `incidents.json` is read from local disk, not
  pushed from a remote server

## Author

Sam
