from flask import Flask, request, jsonify
import uuid

app = Flask(__name__)

@app.route('/v1/upload', methods=['POST'])
def upload():
    # Заглушка: возвращаем фиктивный идентификатор файла
    file_id = str(uuid.uuid4()) + ".jpg"
    return jsonify({"image_id": file_id}), 201

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)