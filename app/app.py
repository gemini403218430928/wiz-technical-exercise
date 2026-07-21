import os
from flask import Flask, render_template, request, redirect, url_for, jsonify
from pymongo import MongoClient
from bson.objectid import ObjectId

app = Flask(__name__)

# Configured via environment variable as required by Wiz exercise criteria
MONGO_URI = os.getenv(
    "MONGO_URI", 
    "mongodb://todo_user:TodoPassword123!@10.0.1.2:27017/todo_db?authSource=todo_db"
)

client = MongoClient(MONGO_URI)
db = client["todo_db"]
todos_collection = db["todos"]

@app.route("/")
def index():
    todos = list(todos_collection.find())
    for todo in todos:
        todo["_id"] = str(todo["_id"])
    return render_template("index.html", todos=todos)

@app.route("/add", methods=["POST"])
def add_todo():
    title = request.form.get("title")
    if title:
        todos_collection.insert_one({"title": title, "completed": False})
    return redirect(url_for("index"))

@app.route("/complete/<todo_id>", methods=["POST"])
def complete_todo(todo_id):
    todos_collection.update_one({"_id": ObjectId(todo_id)}, {"$set": {"completed": True}})
    return redirect(url_for("index"))

@app.route("/delete/<todo_id>", methods=["POST"])
def delete_todo(todo_id):
    todos_collection.delete_one({"_id": ObjectId(todo_id)})
    return redirect(url_for("index"))

@app.route("/healthz")
def healthz():
    # MINOR CHANGE: Added app version and build status to health response
    return jsonify({
        "status": "healthy",
        "version": "1.0.1",
        "deployed_via": "github_actions"
    }), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
