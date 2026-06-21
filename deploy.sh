#!/bin/bash
# Drive上の本体を公開先へ反映（更新時に実行）
# 公開URL（メイン）: https://drumscore.pages.dev   ← Googleログインに github が出ない
# 予備（ソース履歴用）: GitHub リポジトリへも push
set -e
SRC="/Users/wakayamatoshiyuki/Library/CloudStorage/GoogleDrive-toshiyuki.66.dr@gmail.com/マイドライブ/ドラム譜面作成アプリ/files/drum_score.html"
cd "$HOME/drum-score-app"
cp "$SRC" index.html

# --- Cloudflare Pages（メイン公開先） ---
PUB="$(mktemp -d)"
cp index.html "$PUB/index.html"
[ -f rc-purchases.js ] && cp rc-purchases.js "$PUB/rc-purchases.js"   # RevenueCat 公式ラッパー(バンドル)
[ -f _redirects ] && cp _redirects "$PUB/_redirects"   # /admin を index.html で配信するリライト規則
[ -d legal ] && cp -R legal "$PUB/legal"               # 利用規約/プライバシー/特商法（公開ページ）
[ -d articles ] && cp -R articles "$PUB/articles"      # 記事HTML（教材ビューアのiframe）
npx -y wrangler pages deploy "$PUB" --project-name=drumscore --branch=main --commit-dirty=true
rm -rf "$PUB"
echo "デプロイ完了（メイン）: https://drumscore.pages.dev/"

# --- GitHub（ソース履歴の予備バックアップ・URLは共有しない） ---
git add -A
if git diff --cached --quiet; then echo "git: 変更なし"; exit 0; fi
git commit -q -m "update $(date '+%Y-%m-%d %H:%M')"
git push -q
echo "git: バックアップ更新済み"
