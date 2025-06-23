import itertools
from fastapi import FastAPI
from pydantic import BaseModel
import os
import json

WEIGHT_OPTIONS = [150, 200, 250]
app = FastAPI()

# JSONファイルを読み込む
def load_nutrition_data():
    base_dir = os.path.dirname(__file__)
    file_path = os.path.join(base_dir, "data", "nutrition_data.json")
    with open(file_path, "r", encoding="utf-8") as f:
        return json.load(f)

# 入力スキーマ
class BodyInfo(BaseModel):
    age: float | None = None
    gender: float | None = None
    height: float | None = None
    weight: float | None = None

class PFCRequest(BaseModel):
    target_p: float
    target_f: float
    target_c: float
    body_info: BodyInfo | None = None

# スコア関数:PFC目標と実際の差の合計
def pfc_score(combo, target_p, target_f, target_c):
    total_p = sum(f["protein"] for f in combo)
    total_f = sum(f["fat"] for f in combo)
    total_c = sum(f["carbohydrate"] for f in combo)
    return abs(total_p - target_p) + abs(total_f - target_f) + abs(total_c - target_c)


# 重み候補リストを使用した最適な組み合わせ
def find_best_combination(food_list, target_p, target_f, target_c):
    weighted_foods = []
    for food in food_list:
        weighted_foods.extend(generate_weighted_foods(food))

    best_combo = None
    best_score = float("inf")

    for r in range(1, 4):
        for combo in itertools.combinations(weighted_foods, r):
            # 同一食材の重複チェック 例:鶏肉50g + 鶏肉100g → NG
            names = [f["name"] for f in combo]
            if len(set(names)) < len(combo):
                continue

            score = pfc_score(combo, target_p, target_f, target_c)
            if score < best_score:
                best_score = score
                best_combo = combo

    return list(best_combo)

# 重みを加えた候補リスト
def generate_weighted_foods(food):
    return[
        {
            "name": food["name"],
            "unit": food["unit"],
            "amount": weight,
            "protein": food["protein"] * weight / 100,
            "fat": food["fat"] * weight / 100,
            "carbohydrate": food["carbohydrate"] * weight / 100,
            "calories": food["calories"] * weight / 100
        }
        for weight in WEIGHT_OPTIONS
    ]

# APIエンドポイント
@app.post("/suggest_recipe")
def suggest_recipe(pfc: PFCRequest):
    try:
        print("✅リクエスト受信")
        foods = load_nutrition_data()

        weighted_foods = []
        for food in foods:
            weighted_foods.extend(generate_weighted_foods(food))

        best = find_best_combination(weighted_foods, pfc.target_p, pfc.target_f, pfc.target_c)

        return {
            "ingredients": [
                {
                    "name": f["name"],
                    "amount": f["amount"],
                    "unit": f["unit"]
                }
                for f in best
            ],
            "target_pfc": {
                "protein": pfc.target_p,
                "fat": pfc.target_f,
                "carbohydrate": pfc.target_c
            },
            "total_pfc": {
                "protein": sum(i["protein"] for i in best),
                "fat": sum(i["fat"] for i in best),
                "carbohydrate": sum(i["carbohydrate"] for i in best),
                "calories": sum(i["calories"] for i in best)
            },
            "body_info": getattr(pfc, "body_info", None)
        }
    except Exception as e:
        print(f"❌ FastAPI内エラー: {e}")
        return JSONResponse(status_code=500, content={"error": str(e)})

@app.get("/health")
def health_check():
    return {"status": "ok"}