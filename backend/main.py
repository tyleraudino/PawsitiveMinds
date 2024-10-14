from fastapi import FastAPI
import motor.motor_asyncio
from contextlib import asynccontextmanager

client = motor.motor_asyncio.AsyncIOMotorClient()
users: motor.motor_asyncio.AsyncIOMotorCollection = client["database"]["users"]

@asynccontextmanager
async def lifespan(_: FastAPI):
    yield
    client.close()

app = FastAPI(lifespan=lifespan)

@app.get("/user_add")
async def add_user(user_id: int, user_name: str):
    await users.insert_one({"id": user_id, "name": user_name})
    return {"id": user_id, "name": user_name}

@app.get("/user_get")
async def get_user(user_id: int):
    user = await users.find_one({"id": user_id})
    return user