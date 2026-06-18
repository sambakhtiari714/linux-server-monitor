# Linux Server Monitor

A Bash-based Linux monitoring tool that collects system information, checks resource usage, monitors services, and stores logs.

## Features

* System information collection
* Hostname and current user detection
* Uptime monitoring
* Disk usage monitoring
* RAM usage monitoring
* Service status monitoring
* Log file generation
* Colored terminal output

## Technologies Used

* Bash
* Linux
* awk
* sed
* systemctl
* tee

## Monitored Services

Example:

* SSH
* Nginx
* Docker

## Usage

```bash
chmod +x monitor.sh
./monitor.sh
```

## Project Structure

```text
linux-server-monitor/
├── monitor.sh
├── logs/
├── screenshots/
└── README.md
```

## Sample Output

The script generates a monitoring report and stores it in:

```text
logs/system.log
```

## Author

Sam

