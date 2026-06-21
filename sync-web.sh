#!/bin/bash
# Web資産（index.html・legal）を Capacitor の www/ に同梱コピー → cap sync 用
set -e
cd "$(dirname "$0")"
mkdir -p www
cp index.html www/index.html
rm -rf www/legal && cp -R legal www/legal
echo "www/ に index.html と legal/ を同期しました"
