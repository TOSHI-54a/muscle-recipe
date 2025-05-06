import itertools
from fastapi import FastAPI
from pydantic import BaseModel
import os
import json

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

# 最適な組み合わせを探す
def find_best_combination(food_list, target_p, target_f, target_c):
    best_combo = None
    best_score = float("inf")

    for r in range(1, 4): # 1~3品目の組み合わせを試す
        for combo in itertools.combinations(food_list, r):
            score = pfc_score(combo, target_p, target_f, target_c)
            if score < best_score:
                best_score = score
                best_combo = combo

    return list(best_combo)

# APIエンドポイント
@app.post("/suggest_recipe")
def suggest_recipe(pfc: PFCRequest):
    foods = load_nutrition_data()
    best = find_best_combination(foods, pfc.target_p, pfc.target_f, pfc.target_c)

    return {
        "ingredients": [
            {
                "name": f["name"],
                "amount": 100,
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