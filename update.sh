#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd "$SCRIPT_DIR" || exit 1

export HOME="/home/app.e0016372"
export https_proxy="http://172.19.92.23:13128"

SRC_DIR='/nas_train/app.e0016372/train/sft/full'
INTERVAL=7200

parent_name() {
    local dir="$1"
    for ((i=0; i<${2:-1}; i++)); do
        dir=$(dirname "$dir")
    done
    basename "$dir"
}

while true; do
    found=false
    shopt -s nullglob

    for f in $SRC_DIR/*/*/logging.jsonl; do
        if [ -f "$f" ]; then
            dir1=$(parent_name "$f" 2)
            dir2=$(parent_name "$f" 1)
            cp -f "$f" "./${dir1}_${dir2}_logging.jsonl"
            found=true
        fi
    done

    if [ "$found" = true ]; then
        git add .
        git reset --soft HEAD~1 2>/dev/null || true
        git commit -m "auto update $(date '+%F %T')" || true
        git push -f
    fi

    sleep $INTERVAL
done
