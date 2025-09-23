#!/bin/bash
export HOME="/home/app.e0016372"
export https_proxy="http://172.19.92.23:13128"

CONVERTER="$HOME/miniforge3/envs/dev/bin/jupyter-nbconvert"
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd $SCRIPT_DIR

while true; do
    rm -rf ./README_files
    echo "$(seq -s '*' 101 | tr -d '[:digit:]')"
    echo "[$(TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M:%S %Z')]"
    $CONVERTER --execute --inplace ./plotter.ipynb
    $CONVERTER --to html ./plotter.ipynb
    $CONVERTER --to markdown --output README.md ./plotter.ipynb

    git checkout --orphan temp
    git add -A
    git commit -m "Auto sync commit"

    git push -f origin temp:main
    git checkout main
    git reset --hard temp
    git branch -D temp

    sleep 600
done
