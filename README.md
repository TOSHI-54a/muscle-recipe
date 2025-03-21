# 🏋️ Muscle Recipe - トレーニー向けレシピ検索アプリ

### 📌 概要

* トレーニーや健康志向の方に向けて、**体型・目的・食材**からAIがレシピを推薦するWebアプリです。\
「レシピを考えるのが面倒…」という課題をきっかけに開発しました。\
![検索フォームの操作デモ](public/images/Muscle-Recipe.png)


### 🎥 デモ

[![Image from Gyazo](https://i.gyazo.com/bcefc44580282c7fbf931addbee51ef9.gif)](https://gyazo.com/bcefc44580282c7fbf931addbee51ef9)

---

### 🛠 使用技術・ツール

| 分類      | 使用技術                                             |
| ------- | ------------------------------------------------ |
| フロントエンド | Tailwind CSS / Flowbite / JavaScript / Turbo     |
| バックエンド  | Ruby on Rails 7 / Devise / Redis / PostgreSQL    |
| インフラ    | Docker / Fly.io / Cloudflare R2                  |
| その他     | ChatGPT API / RSpec / Rubocop / dotenv / esbuild |

---

### 🔍 主な機能

- ✅ AIレシピ検索 (OpenAI API連携)
- ✅ ゲストでも1回だけ検索可能
- ✅ レシピ保存機能 (ID連動)
- ✅ Myレシピ一覧 + 検索 + 削除
- ✅ チャット機能 (1on1 / グループ)
- ✅ UI: レスポンシブル / ローディングアニメ / 背景画像

---

### 👤 ユーザーについて

| 区分       | 内容                  |
| -------- | ------------------- |
| ゲストユーザー  | 1日1回までAI検索可能 (保存不可) |
| ログインユーザー | 1日5回まで検索 + 保存可能     |

---

### 🚀 開発環境でのセットアップ

```bash
# リポジトリクローン
git clone https://github.com/your-username/muscle_recipe.git
cd muscle_recipe

# 環境変数設定
cp .env.sample .env

# Docker起動
docker-compose up --build

# DB初期化
docker-compose exec web rails db:create db:migrate
```

---

### 🌱 今後追加予定

-

---

### ✍️ 作成者

「人の健康を助ける」プロダクトを作っていきたいです。

👉 [ポートフォリオURL]\
👉 [Twitter / GitHub / Qiita]

---

### 📬 ライセンス

MIT License
