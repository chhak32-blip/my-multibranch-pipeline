"""
Simple Flask web application for multi-branch pipeline demo
"""
from flask import Flask, jsonify, request
import os

app = Flask(__name__)

# Get version from environment or default
VERSION = os.getenv('APP_VERSION', '1.0.0')
BRANCH = os.getenv('GIT_BRANCH', 'unknown')

@app.route('/')
def home():
    """Home page with app info"""
    return jsonify({
        'message': 'Hello from Multi-Branch Pipeline Demo!',
        'version': VERSION,
        'branch': BRANCH,
        'status': 'running'
    })

@app.route('/health')
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'version': VERSION,
        'branch': BRANCH
    })

@app.route('/calculate/<operation>')
def calculate(operation):
    """Simple calculator endpoint"""
    try:
        a = float(request.args.get('a', 0))
        b = float(request.args.get('b', 0))
        
        if operation == 'add':
            result = a + b
        elif operation == 'subtract':
            result = a - b
        elif operation == 'multiply':
            result = a * b
        elif operation == 'divide':
            if b == 0:
                return jsonify({'error': 'Division by zero!'}), 400
            result = a / b
        else:
            return jsonify({'error': 'Invalid operation'}), 400
        
        return jsonify({
            'operation': operation,
            'a': a,
            'b': b,
            'result': result,
            'branch': BRANCH
        })
    
    except ValueError:
        return jsonify({'error': 'Invalid numbers provided'}), 400

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
