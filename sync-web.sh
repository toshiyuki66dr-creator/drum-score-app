#!/bin/bash
# Web資産（index.html・legal）を Capacitor の www/ に同梱コピー → cap sync 用
set -e
cd "$(dirname "$0")"
mkdir -p www
cp index.html www/index.html
[ -f rc-purchases.js ] && cp rc-purchases.js www/rc-purchases.js   # RevenueCat 公式ラッパー(バンドル)
rm -rf www/legal && cp -R legal www/legal
[ -d articles ] && { rm -rf www/articles && cp -R articles www/articles; }   # 記事HTML（教材ビューアのiframe・オフライン同梱）
echo "www/ に index.html と legal/ と articles/ を同期しました"
