from flask import Flask, request
from flask import jsonify

import base64
import os, io, sys, json, socket
import urllib.request, urllib.parse





def recognition_word(access_token, img):
	data = {}
	url = 'https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic?access_token=%s' % access_token
	req = urllib.request.Request(url, method='POST')
	req.add_header('Content-Type', 'application/x-www-form-urlencoded')
	data = urllib.parse.urlencode({'image' : img}).encode()
	with urllib.request.urlopen(req, data) as p:
		res = p.read().decode('utf-8')
		o = json.loads(res)
		return o
		print(o)





app = Flask(__name__)
 
@app.route('/postjson', methods = ['POST'])
def postJsonHandler():
    content = request.get_json()
    return jsonify(recognition_word(content['accessToken'], content['param']))

@app.route('/')
def hello_world():
    return 'Hello, World!'


app.run(host='0.0.0.0', port= 8090)


