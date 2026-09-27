from flask import Flask, request, jsonify
import jwt
import datetime

app = Flask(__name__)
SECRET = "mysecretkey"

# Временное хранилище пользователей
users = {"bob": "qwe123"}

@app.route('/v1/user', methods=['POST'])
def register():
    data = request.get_json()
    login = data.get('login')
    password = data.get('password')
    if login in users:
        return jsonify({"error": "User exists"}), 400
    users[login] = password
    return jsonify({"status": "created"}), 201

@app.route('/v1/token', methods=['POST'])
def login():
    data = request.get_json()
    login = data.get('login')
    password = data.get('password')
    if users.get(login) != password:
        return jsonify({"error": "Invalid credentials"}), 401
    exp = datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(hours=1)
    token = jwt.encode(
        {"sub": login, "exp": exp},
        SECRET,
        algorithm="HS256"
    )
    return jsonify({"token": token})

@app.route('/v1/user', methods=['GET'])
def get_user():
    auth = request.headers.get('Authorization', '')
    if not auth.startswith('Bearer '):
        return jsonify({"error": "Missing token"}), 401
    token = auth[7:]
    try:
        payload = jwt.decode(token, SECRET, algorithms=["HS256"])
        return jsonify({"login": payload['sub']})
    except jwt.ExpiredSignatureError:
        return jsonify({"error": "Token expired"}), 401
    except jwt.InvalidTokenError:
        return jsonify({"error": "Invalid token"}), 401

@app.route('/v1/token/validation', methods=['GET'])
def validate_token():
    auth = request.headers.get('Authorization', '')
    if not auth.startswith('Bearer '):
        return '', 401
    token = auth[7:]
    try:
        jwt.decode(token, SECRET, algorithms=["HS256"])
        return '', 200
    except jwt.ExpiredSignatureError:
        return '', 401
    except jwt.InvalidTokenError:
        return '', 401

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)