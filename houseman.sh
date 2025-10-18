#!/usr/bin/env bash
set -euo pipefail

# Define jobs: "<interval_seconds> <command>"
JOBS_FILE="$HOME/.config/houseman/jobs.txt"

STATE_DIR="/tmp/houseman_$USER"
mkdir -p "$STATE_DIR"

now_epoch=$(date +%s)

while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    interval=$(awk '{print $1}' <<<"$line")
    cmd=$(awk '{ $1=""; sub(/^ /, ""); print }' <<<"$line")

    job_hash=$(echo "$cmd" | md5sum | awk '{print $1}')
    state_file="$STATE_DIR/$job_hash.last"

    last_run=0
    if [[ -f "$state_file" ]]; then
        last_run=$(<"$state_file")
    fi

    elapsed=$((now_epoch - last_run))

    if ((elapsed >= interval)); then
        echo "[$(date)] Running: $cmd" >>$STATE_DIR/log
        set -x
        "$cmd" >>"$STATE_DIR/log" 2>&1
        set +x
        echo "$now_epoch" >"$state_file"
    fi

done <"$JOBS_FILE"
