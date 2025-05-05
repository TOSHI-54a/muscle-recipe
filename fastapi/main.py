from fastapi import FastAPI
from pydantic import BaseModel
import os
import json

app = FastAPI()

def load_nutrition_data():
    base_dir = os.path.dirname(__file__)
    file_path = os.path.join(base_dir, "data", "nutrition_data.json")
    with open(file_path, "r", encoding="utf-8") as f:
        return json.load(f)

class PFCRequest(BaseModel):
    target_p: float
    target_f: float
    target_c: float

@app.post("/suggest_recipe")
def suggest_recipe(pfc: PFCRequest):
    data - load_nutrition_data()

    return {
        "ingredients": data[:3],
        "target_pfc": {
            "protein": input.target_p,
            "fat": input.target_f,
            "carbohydrate": input.target_c
        },
        "total_pfc": {
            "protein": sum(i["protein"] for i in data[:3]),
            "fat": sum(i["fat"] for i in data[:3]),
            "carbohydrate": sum(i["carbohydrate"] for i in data[:3]),
            "calories": sum(i["calories"] for i in data[:3])
        },
        "body_info": input.body_info
    }