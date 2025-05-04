from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class PFCRequest(BaseModel):
    target_p: float
    target_f: float
    target_c: float

@app.post("/suggest_recipe")
def suggest_recipe(pfc: PFCRequest):
    return {
        "recipe_name": "高たんぱくサラダチキンボウル",
        "ingredients": ["鶏むね肉", "玄米", "ブロッコリー"],
        "protein": pfc.target_p,
        "fat": pfc.target_f,
        "carbohydrate": pfc.target_c
    }