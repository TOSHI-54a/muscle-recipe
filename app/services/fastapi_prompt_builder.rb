class FastapiPromptBuilder
    def self.build(recipe_data)
    ingredients_raw = recipe_data["ingredients"]
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
        - JSON形式のみで出力（コードブロックや説明文なし）
    PROMPT
    end
end
