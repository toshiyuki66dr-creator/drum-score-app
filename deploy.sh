#!/bin/bash
# Drive上の本体をGitHub Pagesへ反映（更新時に実行）
set -e
SRC="/Users/wakayamatoshiyuki/Library/CloudStorage/GoogleDrive-toshiyuki.66.dr@gmail.com/マイドライブ/ドラム譜面作成アプリ/files/drum_score.html"
cd "$HOME/drum-score-app"
cp "$SRC" index.html
git add -A
if git diff --cached --quiet; then echo "変更なし"; exit 0; fi
git commit -q -m "update $(date '+%Y-%m-%d %H:%M')"
git push -q
echo "デプロイ完了: https://toshiyuki66dr-creator.github.io/drum-score-app/"
