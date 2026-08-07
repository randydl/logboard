#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd "$SCRIPT_DIR" || exit 1

export HOME="/home/app.e0016372"
export https_proxy="http://172.19.92.23:13128"

SRC_DIRS=(
    '/nas_train/app.e0016372/train/LLaVA-OneVision-1.5-4B'
    '/nas_train/app.e0016372/train/LLaVA-OneVision-1.5-4B/r1_10'
    # '/nas_train/app.e0016372/train/MiniCPM-V-4.6-4B/openbee'
    # '/nas_train/app.e0016372/train/LLaVA-OneVision-1.5-4B/openbee'
)
INTERVAL=3600

while true; do
    found=false

    for src in "${SRC_DIRS[@]}"; do
        for f in "$src"/*/logging.jsonl; do
            [ -f "$f" ] || continue
            rel_path=$(realpath --relative-to="$src" "$(dirname "$f")")
            cp -f "$f" "./${rel_path//\//_}_logging.jsonl"
            found=true
        done
    done

    if [ "$found" = true ]; then
        git add .
        git reset --soft HEAD~1 2>/dev/null || true
        git commit -m "auto update $(date '+%F %T')" || true
        git push -f
    fi

    sleep $INTERVAL
done
