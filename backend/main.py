from typing import Optional
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from bson import ObjectId
import motor.motor_asyncio

app = FastAPI()

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # to put frontend url
    allow_credentials=True,
    allow_methods=["*"],  # allows GET, POST, OPTIONS, etc.
    allow_headers=["*"],  # allows all headers
)

# mongo connection
client = motor.motor_asyncio.AsyncIOMotorClient("mongodb://localhost:27017/")
db = client["your_database"]
collection = db["your_collection"]

# pydantic models
# ---------------

# for item data

class Item(BaseModel):
    name: str
    description: str

# for goal data
class Goal(BaseModel):
    title: str
    description: str

# for updating goals
class UpdateGoal(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None

# get request to fetch all goals
@app.get("/goals/")
async def get_goals():
    goals = []
    cursor = collection.find({})
    async for document in cursor:
        document.pop("_id")  # Remove MongoDB's internal ID field
        goals.append(document)
    return goals

# post request to add data
@app.post("/data")
async def post_data(item: Item):
    new_data = item.dict()
    result = await collection.insert_one(new_data)
    if result.inserted_id:
        return {"message": "Data inserted successfully!"}
    else:
        raise HTTPException(status_code=400, detail="Data insertion failed")

# post request to create a goal
@app.post("/goals/")
async def create_goal(goal: Goal):
    new_goal = goal.dict()
    result = await collection.insert_one(new_goal)
    if result.inserted_id:
        return {"message": "Goal created successfully!", "goal_id": str(result.inserted_id)}
    else:
        raise HTTPException(status_code=400, detail="Goal creation failed")
    
# post request to delete a goal
@app.delete("/goals/{goal_id}")
async def delete_goal(goal_id: str):
    try:
        object_id = ObjectId(goal_id) # converts goal_id to MongoDB's ObjectID
        print(f"Converted goal_id to ObjectId: {object_id}")
    except Exception as e:
        print(f"Invalid ObjectId for goal_id: {goal_id}, error: {e}")
        raise HTTPException(status_code=400, detail="Invalid goal ID format")
    # attempts to delete the document by ID
    result = await collection.delete_one({"_id": object_id})
    print(f"Deletion result for goal_id {goal_id}: {result.deleted_count}")
    if result.deleted_count == 1:
        return {"message": "Goal deleted successfully!"} # expected result
    else:
        raise HTTPException(status_code=404, detail="Goal not found.")
    
# request to modify goals
@app.put("/goals/{goal_id}")
async def update_goal(goal_id: str, goal: UpdateGoal):
    try:
        object_id = ObjectId(goal_id)  # Convert goal_id to ObjectId
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid goal ID format")

    # Create dictionary of updates, excluding None values
    updated_data = {k: v for k, v in goal.dict().items() if v is not None}

    if updated_data:
        result = await collection.update_one({"_id": object_id}, {"$set": updated_data})
        if result.modified_count == 1:
            return {"message": "Goal updated successfully!"}
        else:
            raise HTTPException(status_code=404, detail="Goal not found or no changes made")
    else:
        raise HTTPException(status_code=400, detail="No valid fields provided for update")