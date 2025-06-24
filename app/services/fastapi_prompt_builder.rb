class FastapiPromptBuilder
    def self.build(recipe_data)
    ingredients_raw = recipe_data["ingredients"]
    # binding.pry
    return "食材データが取得できません" if ingredients_raw.nil?
    ingredients = ingredients_raw.map do |i|
        "- #{i["name"]}: #{i["amount"]}#{i["unit"]}"
    end.join("\n")

    age    = recipe_data.dig("body_info", "age")
    gender = recipe_data.dig("body_info", "gender")
    height = recipe_data.dig("body_info", "height")
    weight = recipe_data.dig("body_info", "weight")

    <<~PROMPT
        以下の条件を満たすレシピをJSON形式で提案してください:

        ■ 基本情報:
        - 年齢: #{age || "指定なし"}歳
        - 性別: #{gender || "指定なし"}
        - 身長: #{height || "指定なし"}cm
        - 体重: #{weight || "指定なし"}kg

        ◼️ 使用する食材(1人前):
        #{ingredients}

        ◼️ 栄養素目標（PFC）:
        - タンパク質: #{recipe_data.dig("target_pfc", "protein")}g
        - 脂質: #{recipe_data.dig("target_pfc", "fat")}g
        - 炭水化物: #{recipe_data.dig("target_pfc", "carbohydrate")}g

        ◼️ 実際の合計値:
        - タンパク質: #{recipe_data.dig("target_pfc", "protein")}g
        - 脂質: #{recipe_data.dig("target_pfc", "fat")}g
        - 炭水化物: #{recipe_data.dig("target_pfc", "carbohydrate")}g
        - カロリー: #{recipe_data.dig("target_pfc", "calories")}kcal

        制約:
        - 出力は以下の JSON フォーマットの通りに、**コードブロック（```json）を含めて**生成してください。
        - 説明文やその他の装飾は不要です。以下のような形で返答してください。

        ```json
        {
            "recipe": {
                "title": "チーズ入りジャガイモグラタン",
                "description": "ジャガイモとチーズを組み合わせた、簡単で美味しいグラタンです。",
                "ingredients": [
                    { "name": "ジャガイモ", "amount": "2個" },
                    { "name": "チーズ", "amount": "100g" },
                    { "name": "牛乳", "amount": "200ml" }
                ],
                "steps": [
                    "ジャガイモの皮をむいてスライスする。",
                    "耐熱皿に並べ、チーズと牛乳をかける。",
                    "オーブンで180℃で20分焼く。"
                ],
                "nutrition": {
                    "calories": "350kcal",
                    "protein": "15g",
                    "fat": "20g",
                    "carbohydrates": "30g"
                }
            }
        }
    PROMPT
    end
end
