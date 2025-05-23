module ChatGptServiceMock
    def mock_chatgpt_response(recipe_title: "モックレシピ")
        allow_any_instance_of(ChatGptService).to receive(:fetch_recipe).and_return(
            {
                "recipe" => {
                    "title" => "モックレシピ",
                    "description" => "テスト用の説明",
                    "ingredients" => [ { "name" => "卵", "amount" => "2個" } ],
                    "step" => [ "混ぜる", "焼く" ],
                    "nutrition" => {
                        "calories" => "300kcal",
                        "protein" => "20g",
                        "fat" => "10g",
                        "carbohydrates" => "30g"
                    }
                }
            }
        )
    end

    def mock_chatgpt_response_nil
        allow_any_instance_of(ChatGptService).to receive(:fetch_recipe).and_return(nil)
    end

    def mock_chatgpt_raise(error_class)
        allow_any_instance_of(ChatGptService).to receive(:fetch_recipe).and_raise(error_class)
    end

    def mock_pfc_response
        allow_any_instance_of(ChatGptService).to receive(:fetch_recipe).and_return(
            {
                recipe: {
                    title: "テストレシピ",
                    description: "テスト説明",
                    ingredients: [ { name: "鶏むね肉", amount: "100g" } ],
                    steps: [ "焼く", "食べる" ],
                    nutrition: {
                    calories: "300kcal", protein: "25g", fat: "8g", carbohydrates: "45g"
                    }
                }
            }
        )
    end
end
