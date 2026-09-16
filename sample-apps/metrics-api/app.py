from flask import Flask, jsonify, request
import time
app = Flask(__name__)
_allocations = []
@app.get('/health')
def health(): return jsonify(status='ok')
@app.get('/cpu')
def cpu():
    seconds = min(int(request.args.get('seconds', '15')), 120)
    end = time.time() + seconds
    x = 0
    while time.time() < end: x = (x * 13 + 7) % 10000019
    return jsonify(seconds=seconds, result=x)
@app.get('/memory')
def memory():
    mb = min(int(request.args.get('mb', '100')), 700)
    seconds = min(int(request.args.get('seconds', '15')), 120)
    block = bytearray(mb * 1024 * 1024)
    _allocations.append(block)
    time.sleep(seconds)
    _allocations.remove(block)
    return jsonify(mb=mb, seconds=seconds)
