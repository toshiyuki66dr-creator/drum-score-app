# App Store 公開 実作業ロードマップ ＋ 審査リスク

> 前提の最終仕様（確定）
> - 無料：広告あり／セットリスト1個／曲25曲／本番モード可／無料教材／プレミアム試読
> - Pro：全機能・セットリスト無制限・曲無制限・PDF出力・プレミアム教材すべて・耳コピ自動検出・ページターナー連携・（共有・バンド管理＝**未実装**）・広告非表示
> - 価格：月¥480（7日無料）／年¥4,980（7日無料）／Lifetime¥19,800（トライアル無し）。無料期間後はApp Store標準の自動更新。

---

## ★最初に直す必要があるもの（公開ブロッカー）
本番ビルド前に**必ず**対応（詳細は末尾「審査リスク」）：
1. **テスト用「Proにする（テスト）」トグルを削除**（IAP以外でPro解放＝即リジェクト）。
2. **`/admin`（教材管理）をiOSビルドに載せない**。
3. **Stripe等の外部決済導線をiOSで無効化**（デジタル解放はIAPのみ）。
4. **Google Driveバックアップは iOS で隠す/無効**（WebViewのGoogleログインは弾かれる）。
5. **未実装機能（セットリスト共有・バンド管理）を「公開時の宣伝文・ペイウォール」から出さない**（作ってから載せる／"近日"表記）。

---

## Phase 0：Apple Developer 登録（あなたの作業）
- [ ] developer.apple.com で **Apple Developer Program 登録（$99/年・個人が早い）**。2FA・各種規約に同意。
- [ ] App Store Connect → **「契約/税金/口座（Agreements, Tax, and Banking）」で“有料App契約”を締結**（※IAPに必須。未締結だと課金商品が出ない）。
- [ ] **Sandboxテスター**用のテスト用Apple IDを1つ作成（課金テスト用）。

## Phase 1：開発環境・素材
- [ ] **Xcode** をインストール（Mac App Store）＋ コマンドラインツール。
- [ ] **Bundle ID** を決定（例 `com.<あなた>.drumscore`）。Developerポータルで **App ID 作成＋In-App Purchase 有効化**。
- [ ] **アプリアイコン1024px**・各サイズ、**スプラッシュ画像**、スクショ素材（後述）。

## Phase 2：Capacitor 化（Webをネイティブで包む）
- [ ] プロジェクト作成：`npm init` → `npm i @capacitor/core @capacitor/cli @capacitor/ios`
- [ ] `npx cap init "DrumScore" "com.xxx.drumscore"`（webDir=`www`）
- [ ] **現行 `index.html` 等を `www/` にコピー＝オフライン同梱**（リモート全読込はしない）。
- [ ] `npx cap add ios` → `npx cap sync`
- [ ] `npx cap open ios`（Xcode）で **署名チーム・Bundle ID・バージョン・アイコン・スプラッシュ** 設定。
- [ ] **Info.plist** 追記：`NSUserTrackingUsageDescription`（ATT）／`NSMicrophoneUsageDescription`（ライブ耳コピでマイク使用時）／必要なら音声バックグラウンド／`ITSAppUsesNonExemptEncryption=false`。
- [ ] **iOS版から除外/無効化**：管理画面(`/admin`)・Google Driveバックアップ・Stripe・テストProトグル。
- [ ] シミュレータ＆実機で全機能の動作確認（オフライン含む）。

## Phase 3：RevenueCat（アプリ内課金）
- [ ] **App Store Connect でIAP商品を作成**：
  - サブスクグループ「Pro」→ **月額¥480**・**年額¥4,980**（各に**7日間の無料トライアル＝Introductory Offer**）
  - **非消費型**「Lifetime ¥19,800」（トライアル無し）
  - 各商品の表示名・説明・レビュー用スクショ・地域価格を登録。
- [ ] **RevenueCat** プロジェクト作成 → 3商品を登録 → **Entitlement「pro」** に3つとも紐付け → Offering/Packages 作成。
- [ ] `npm i @revenuecat/purchases-capacitor` → APIキーで初期化。
- [ ] アプリ側を**RevenueCatのエンタイトルメントで `isPro()` 判定に置換**（現在のlocalStorage判定を差し替え）。購入で即`isPro`更新。
- [ ] **ペイウォールに必須要素**：購入ボタン（月/年/Lifetime）・**「購入を復元」ボタン**・**価格/期間/自動更新/解約方法・利用規約/プラポリのリンク**（ガイドライン3.1.2）。
- [ ] **Sandboxで課金テスト**（トライアル開始→自動更新→復元→Lifetime購入）。

## Phase 4：AdMob（下部バナー）
- [ ] AdMobでアプリ登録 → **iOSバナーのユニットID**作成（最初はテストID）。
- [ ] `npm i @capacitor-community/admob` → 初期化。
- [ ] **ATT同意**（iOS14.5+）＋ **UMP同意**（EEA）→ 拒否時は**非パーソナライズ広告**。
- [ ] 表示制御：**本番モード/エディタは非表示**、ホーム/教材/ストアで表示、**`isPro`なら全非表示**。
- [ ] Info.plist に `GADApplicationIdentifier` ＋ `SKAdNetworkIdentifiers`。実機でテスト広告確認→本番ユニットへ。

## Phase 5：法務・メタデータ
- [ ] **プライバシーポリシー**＋**利用規約(EULA)** をWeb公開（既存Cloudflareで可）。アプリ内とApp Store Connectにリンク。
- [ ] App Store Connectの **App Privacy（データ収集申告）**：AdMob（識別子/利用データ）・IAP購入情報を正確に。
- [ ] ストア掲載情報：**アプリ名・サブタイトル・説明（冒頭にセットリスト/本番モードを強調）・キーワード・スクショ（6.7"/6.5"/必要なら5.5"・iPad）・カテゴリ=ミュージック・年齢区分・サポートURL・プラポリURL**。
- [ ] **審査メモ**：IAPの説明、ATTの説明、（必要なら）デモ手順。

## Phase 6：TestFlight
- [ ] Xcodeで **Archive → App Store Connect へアップロード**。
- [ ] **TestFlight 内部テスト**（自分）→ 課金（Sandbox/TestFlight）・広告・全導線を確認。必要なら外部テスト（ベータ審査あり）。

## Phase 7：申請
- [ ] App Store Connect で **審査提出**。リジェクト時は理由に対応して再提出。
- [ ] 承認後 **段階的リリース**で公開。

---

## 現時点で審査に通らない可能性がある箇所（要対応）
| # | リスク | ガイドライン | 対応 |
|---|---|---|---|
| 1 | **テスト用Proトグル＝IAP以外でPro解放** | 3.1.1 | 本番ビルドで削除（RevenueCatのみで解放） |
| 2 | **`/admin` 管理画面が同梱** | 2.3.1/隠し機能 | iOSビルドから除外 |
| 3 | **Stripe等の外部決済でデジタル解放** | 3.1.1 | iOSで無効化（IAPのみ） |
| 4 | **Google Drive OAuth が WebViewで動かない**（壊れた機能） | 2.1 | iOSで非表示/無効、または将来ネイティブ実装 |
| 5 | **未実装のPro機能を宣伝**（共有・バンド管理） | 2.3.1 正確なメタデータ | 作ってから載せる or 文言から外す/"近日" |
| 6 | **サブスク必須表記・復元ボタンが無い** | 3.1.2 | ペイウォールに価格/期間/自動更新/規約リンク＋復元を実装 |
| 7 | **プライバシーポリシー未整備** | 5.1.1 | 公開してURLを登録 |
| 8 | **ATT未実装で広告がIDFA利用** | 5.1.2/ATT | ATTプロンプト＋Info.plist文言、拒否時は非パーソナライズ |
| 9 | **マイク用途説明が無い**（ライブ耳コピ） | 5.1.1 | `NSMicrophoneUsageDescription` を明記 |
| 10 | **アプリ全体をリモート読込**（4.2/2.5.2） | 4.2 | Web資産を同梱しオフライン動作 |
| 11 | **アフィリ/外部リンクがデジタル購入導線に見える** | 3.1.1/3.1.3 | 物理商品/外部サイトのみ・広告/PR表記維持 |
| 低 | 最低限の機能(4.2) | 4.2 | 実質的な譜面エディタ＝概ねOK（オフライン動作で担保） |

> アカウント機能は未導入のため **アカウント削除対応は不要**（将来ログインを入れたら必須）。

---

## まず着手すべき順番（最短ルート）
1. **Phase 0（あなた）**：Developer登録＋有料App契約＋Sandboxテスター。
2. 並行で**ブロッカー①〜⑤の修正**（こちらで対応：テストトグル除去・admin除外・Stripe無効・GDrive非表示・宣伝文言の整理）。
3. **Phase 2 Capacitor化**（こちらで雛形作成）→ 実機で動作確認。
4. **Phase 3 RevenueCat**（商品作成はあなた＝App Store Connect、結線はこちら）。
5. Phase 4 AdMob → Phase 5 法務 → Phase 6 TestFlight → Phase 7 申請。
