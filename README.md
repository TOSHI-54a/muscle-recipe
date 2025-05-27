# 🏋️ Muscle Recipe - トレーニー向けレシピ検索アプリ

**ユーザーの筋トレを支える”栄養×AI”レシピ検索アプリ**\
食材やPFCバランス（タンパク質・脂質・炭水化物）を入力すると、AIがユーザーに合ったレシピを提案します。\
[▶︎ webサイトを開く](https://www.muscle-recipe.com)
![README_TopImage](public/images/Muscle-Recipe.png)

<br/>

# 🎥 デモ

*操作デモ*
[![操作デモ](https://i.gyazo.com/bcefc44580282c7fbf931addbee51ef9.gif)](https://gyazo.com/bcefc44580282c7fbf931addbee51ef9)

<br/>

# ✨主な機能 / Features
- 🤖AIによるレシピ提案（具材検索・PFC検索）
- 👦ユーザーの身体情報（年齢・性別・身長・体重）に基づいたレシピを提案
- 🍗指定されたPFCに基づき具材を選定し、レシピを提案
- 🥕使用・除外したい食材の指定や調味料の指定が可能
- 📊レシピにはカロリー・PFC表示付き
- 🩷レシピ保存＆お気に入り機能
- 👤ゲストユーザー対応（検索回数制限あり）
- 💬チャット機能（１対１ / グループ）

<br/>

| トップ画面 | レスポンシブデザイン |
| --- | --- |
| ![top](public/images/README_images/top.png) | ![design](public/images/README_images/recipe_design.png) |
| 具材検索 | PFC検索 |
| ![具材](public/images/README_images/search_ing.png) | ![PFC](public/images/README_images/search_pfc.png) |
| 保存レシピ | お気に入りレシピ |
| ![ing](public/images/README_images/save_all.png)| ![like](public/images/README_images/save_like.png) |
| ログイン | ユーザー登録 |
| ![login](public/images/README_images/login.png) | ![user_new](public/images/README_images/user_new.png) |
| チャット選択 | チャット画面 |
| ![chat_index](public/images/README_images/chat_index.png) | ![chat_show](public/images/README_images/chat_show.png) |

<br/>

# 🛠 使用技術

| 分類      | 使用技術                                             |
| ------- | ------------------------------------------------ |
| バックエンド  | Ruby / Ruby on Rails 7 / Python3 / Devise / Redis | 
| フロントエンド | JavaScript / Turbo / TailwindCSS / Flowbite |
| CSS           | TailwindCSS / Flowbite |
| DB            | PostgresSQL |
| 外部API       | OpenAI(GPT-4o mini) / FastAPI |
| テスト        | RSpec / Rubocop / SimpleCov |
| インフラ      | Docker / Fly.io  |
| 認証          | Devise / Google OAuth |
| CI/CD        | GitHub Action |

<br/>

# 💡開発背景 / サービスへの想い
このアプリは、私自身の実体験をきっかけに生まれました。\
筋トレに励む中で「食事の大切さ」は痛感していたものの、毎回レシピを考えたり探したりするのがとても面倒でした。\
加えて、レシピ本で紹介されている料理は、凝った調味料や珍しい食材を使用していることも少なくなく、日常的に取り入れるのが難しいと感じていました。\
そこで私は、ユーザーの体型や性別、目的に合わせたレシピを簡単に探せるサービスがあれば、もっと効率的で楽に健康管理ができるのではと考えました。

このアプリでは、
  - ユーザーの身体情報（年齢・性別・身長・体重）に合わせた提案
  - 使用したい or 避けたい具材の選択
  - 「基本的な調味料」など、調味料の種類を選択可能
  - PFCバランス（タンパク質・脂質・炭水化物）やカロリーも自動で表示
  
といった機能を実装しています。

### **「あなたは筋トレ、献立はAIに」**

この言葉をコンセプトに、毎日の食事をもっとシンプルに、そしてもっと“あなたに合ったもの”にできるようサポートします。\
<br/>


# ER図
![ER図](public/images/README_images/MuscleRecipe_2.drawio.png)
\
<br/>

# 🧪テストカバレッジ（[SimpleCov](https://github.com/simplecov-ruby/simplecov)）
| 項目 | カバレッジ率 |
|---|---|
| 全体 | 75.24% |
| Models | 90.63% |
| Controllers | 90.95% |

*Rspec + FactoryBot によるテスト実施。

<br/>

# 👤 ユーザーについて

| 区分       | 内容                  |
| -------- | ------------------- |
| ゲストユーザー  | 1日1回までレシピ検索可能 (保存不可) |
| ログインユーザー | 1日5回までレシピ検索可能（保存可能 + お気に入り機能）  |  
<br/>

# 🌱 今後の開発予定

- 保存レシピのSNSシェア機能
- グループチャット機能の拡充
- レシピ検索での目的のリスト化（筋肥大 / 減量 /脂肪燃焼）
