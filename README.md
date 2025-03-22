# 🏋️ Muscle Recipe - トレーニー向けレシピ検索アプリ

### 📌 概要

* トレーニーや健康志向の方に向けて、**体型・目的・食材**からAIがレシピを推薦するWebアプリです。\
「レシピを考えるのが面倒…」という課題をきっかけに開発しました。\
![検索フォームの操作デモ](public/images/Muscle-Recipe.png)

---

### 📱URL
[Muscle Recipe](https://www.muscle-recipe.com)

---

### 🎥 デモ

[![Image from Gyazo](https://i.gyazo.com/bcefc44580282c7fbf931addbee51ef9.gif)](https://gyazo.com/bcefc44580282c7fbf931addbee51ef9)

---

### 🛠 使用技術・ツール

| 分類      | 使用技術                                             |
| ------- | ------------------------------------------------ |
| バックエンド | Ruby / Ruby on Rails 7 |
| フロントエンド | JavaScript |
| CSS | TailwindCSS / Flowbite |
| DB | PostgresSQL |
| Web API | OpenAI(GPT-4o mini) |
| バックエンド  | Ruby on Rails / Devise / Redis / PostgreSQL    |
| インフラ    | Docker / Fly.io  |
| 認証 | Devise / Google OAuth |
| その他     | RSpec / Rubocop / dotenv / GitHub Action |

---

### 🔍 主な機能

- ✅ AIレシピ検索 (OpenAI API連携)
- ✅ ゲストでも1日1回だけ検索可能
- ✅ レシピ保存機能 (ID連動)
- ✅ Myレシピ一覧 + 検索 + 削除
- ✅ チャット機能 (1on1 / グループ)
- ✅ UI: レスポンシブル / ローディングアニメ

---

### ER図

-

---

### 👤 ユーザーについて

| 区分       | 内容                  |
| -------- | ------------------- |
| ゲストユーザー  | 1日1回までAI検索可能 (保存不可) |
| ログインユーザー | 1日5回まで検索 + 保存可能     |

---

### 🌱 今後追加予定

- 保存レシピのSNSシェア機能

---

### ✍️ 作成者コメント

「人の健康を助ける」プロダクトを作っていきたいです。


---
