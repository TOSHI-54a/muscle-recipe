require "httparty"
require "dotenv/load" unless Rails.env.production?

class ChatGptService
  API_URL = "https://api.openai.com/v1/chat/completions"

  def initialize(api_key = ENV["CHATGPT_API_KEY"])
    @api_key = api_key
  end

  def fetch_recipe(prompt)
    Rails.logger.debug "Fetching recipe from ChatGPT..."

    request = request_body(prompt)
    Rails.logger.debug "ChatGPT API Request: #{request.to_json}"

    response = HTTParty.post(
      API_URL,
      headers: request_headers,
      body: request.to_json
    )

    Rails.logger.debug "ChatGPT API Response: #{response.inspect}"
    parse_response(response)
  rescue StandardError => e
    Rails.logger.error "Error in fetch_recipe: #{e.message}"
    nil
  end

  private

  def request_headers
    {
      "Authorization" => "Bearer #{@api_key}",
      "Content-Type" => "application/json"
    }
  end

  def request_body(prompt)
    {
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: "You are a professional nutritionist. Generate structured JSON-formatted healthy recipes." },
        { role: "user", content: generate_prompt(prompt) }
      ],
      max_tokens: 1000,
      temperature: 0.3
    }
  end

  def parse_response(response)
    if response.success?
      parsed_data = JSON.parse(response.body)
      recipe_json = parsed_data.dig("choices", 0, "message", "content")

      # 余分な```json ... ```を削除
      if recipe_json.start_with?("```json")
        recipe_json = recipe_json.gsub(/```json|```/, "").strip
      end

      # JSON 形式でのレスポンスをパース
      begin
        formatted_recipe = JSON.parse(recipe_json)
        Rails.logger.debug "Formatted Recipe: #{formatted_recipe.inspect}"
        formatted_recipe
      rescue JSON::ParserError
        raise "ChatGPT のレスポンスが JSON 形式ではありません。"
      end
    else
      raise "ChatGPT API Error: #{response.body}"
    end
  end

  def generate_prompt(request_payload)
    Rails.logger.debug "リクエストペイロード: #{request_payload.inspect}"

    <<~PROMPT
      以下の条件に合うレシピを JSON 形式で提案してください:

      - 年齢: #{request_payload.dig(:body_info, :age) || "指定なし"}歳
      - 性別: #{request_payload.dig(:body_info, :gender) || "指定なし"}
      - 身長: #{request_payload.dig(:body_info, :height) || "指定なし"}cm
      - 体重: #{request_payload.dig(:body_info, :weight) || "指定なし"}kg
      - 料理の複雑度: #{request_payload[:recipe_complexity] || "指定なし"}
      - 使用したい具材: #{Array(request_payload.dig(:ingredients, :use)).reject(&:blank?).join(", ") || "指定なし"}
      - 避けたい具材: #{Array(request_payload.dig(:ingredients, :avoid)).reject(&:blank?).join(", ") || "指定なし"}
      - 要望: #{request_payload.dig(:preferences, :goal) || "指定なし"}
      - 調味料の指定: #{request_payload[:seasonings] || "指定なし"}

      **JSON 形式で出力してください。**
      **注意: コードブロック (```json ... ```) を使用せず、純粋な JSON のみを出力し、それ以外のテキストを含めないでください。**
      **「料理名:」「説明:」などの余分な装飾は不要です。**
      **以下のフォーマットを厳密に守ってください:**

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
      ```
    PROMPT
  end
end
