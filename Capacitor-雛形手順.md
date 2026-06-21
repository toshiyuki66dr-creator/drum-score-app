# Capacitor 雛形・Bundle ID・Info.plist 下準備（iOSラッパ化）

> 目的：現行の単一HTML（`index.html`）＋`legal/` をそのまま **iOSネイティブアプリ**として包む。
> 前提：macOS／Xcode／Node。実機ビルドは Apple Developer 承認後でOK（雛形は今作れる）。

---

## 1. Bundle ID（提案）
- 推奨：**`jp.drumnotes.app`**（drumnotes.jp の逆ドメイン・簡潔）
  - 代替：`jp.drumnotes.drumnotes` / `com.drumnotes.app`
- App名（表示名）：**DrumNotes**

## 2. Capacitor プロジェクト作成（コマンド）
リポジトリ直下で：
```bash
npm init -y
npm i @capacitor/core
npm i -D @capacitor/cli
npm i @capacitor/ios
# Web資産の置き場所を www に（オフライン同梱）
mkdir -p www && cp index.html www/ && cp -R legal www/
npx cap init "DrumNotes" "jp.drumnotes.app" --web-dir=www
npx cap add ios
npx cap sync
npx cap open ios   # Xcodeが開く
```
> 以後、`index.html`/`legal` を更新したら：`cp index.html www/ && cp -R legal www/ && npx cap sync`

## 3. capacitor.config（生成後に確認/調整）
`capacitor.config.json`（または .ts）：
```json
{
  "appId": "jp.drumnotes.app",
  "appName": "DrumNotes",
  "webDir": "www",
  "ios": { "contentInset": "always" }
}
```
- リモート読み込みはしない（`server.url` は設定しない＝**バンドル資産でオフライン動作**＝審査安定）。

## 4. Info.plist 下準備（Xcode の Target → Info）
必要に応じ追加：
| キー | 値/用途 |
|---|---|
| `CFBundleDisplayName` | DrumNotes |
| `ITSAppUsesNonExemptEncryption` | `NO`（標準HTTPSのみ＝輸出申告を簡略化） |
| `NSUserTrackingUsageDescription` | 「広告の最適化のために使用します」等（**AdMob/ATT導入時**） |
| `NSMicrophoneUsageDescription` | 「耳コピのライブ入力で使用します」（**マイク使用機能を残す場合のみ**） |
| `GADApplicationIdentifier` | AdMobアプリID（**AdMob導入時**） |
| `LSApplicationQueriesSchemes` / URL Scheme | **Googleドライブ連携をネイティブ対応する場合**のOAuthコールバック用 |
- アイコン（1024px）・スプラッシュは Xcode のアセットに設定。
- オーディオ（メトロノーム/再生）：必要なら `AVAudioSession` のカテゴリ設定（ネイティブ）。

## 5. 公開前ブロッカー（コード側・対応状況）
- [x] **テスト用Proトグル** → `DEV_MODE=false` で非表示化済み（特別コードでテスト可）
- [x] **Stripe** → 実体なし（コメントのみ・`PAYMENTS_LIVE=false`）＝デジタル解放の外部決済導線なし
- [x] **/admin** → iOSバンドルに該当ファイル無し＋UI導線なし＋パスワード（ハッシュ）保護＝**実質到達不可**
- [x] **実験的な自動採譜（音源→譜面）** → `SHOW_EXPERIMENTAL_TRANSCRIBE=false`＝非表示
- [ ] **Googleドライブ・バックアップ** → 後述（Webは動作・Capacitorは要ネイティブ対応）
- [ ] IAP（RevenueCat）・AdMob・ATT・復元ボタン・サブスク表記 → Phase2で実装

## 6. Googleドライブ・バックアップの扱い（重要）
現状＝**Google Identity Services（GISトークンクライアント）＋`drive.appdata`**（アプリ専用フォルダ・最小権限）。
- **Web（Safari/Chrome）**：動作する設計（要：OAuthクライアントの承認済みオリジンに公開ドメインを登録）。
- **Capacitor（WKWebView）**：**Googleは埋め込みWebViewでのOAuthを禁止**（`disallowed_useragent`）＋webviewオリジン（`capacitor://localhost`）はWebクライアントの承認オリジンに不可 → **そのままでは動かない**。
- 対応案：
  - **(A) ネイティブ対応**：`@codetrix-studio/capacitor-google-auth` 等でネイティブにアクセストークン取得→既存の `GDrive.read/write`（Drive REST）はほぼ流用可。iOS用OAuthクライアントID＋URLスキーム設定が必要。
  - **(B) v1は据え置き**：iOSビルドでは ☁バックアップ を**非表示**（Web版のみ提供）。後でAに対応。
- 審査：Googleドライブは「ストレージ連携」であり**アカウント認証ではない**ため、**Sign in with Apple は原則不要**（低リスク）。ただし**壊れた機能のまま公開は不可**（要：A対応 or B非表示）。

## 7. 次の実装（Phase2・Apple承認後）
RevenueCat（IAP・復元・サブスク表記）→ AdMob（バナー・ATT・UMP）→ Sandbox検証 → TestFlight → 申請。
