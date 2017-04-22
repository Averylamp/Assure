# Media Lab Design Hackathon
# by Ethan Weber, Avery Lamp, and Kenny Friedman 
# April 21, 2017

#import the main flask, and request (to handle post request parameters) 
from flask import Flask, request
import requests, json
#begin a flask app
app = Flask(__name__)

#Handle post requests from the root directory
@app.route('/', methods=['POST'])
def processIncomingPostData():
	print "this should be working"
	#ask for data by calling request.values.get("PARAMETER_NAME")
	print request.values.get("from_mac")
	print request.values.get("device")
	print request.values.get("rssi")
	if request.values.get("from_mac") is None:
		print("invalid params")
		return "No valid parameters"

	data = {}
	data["fromMAC"] =  request.values.get("from_mac")
	device = request.values.get("device")
	rssi =  request.values.get("rssi")
	data["rssi"] = rssi
	data["distance"] = str(10 ** ((-45 - int(rssi)) / 20.0))
	print("Distance - {}".format(data["distance"]))
	data = json.dumps(data)
	parse_headers = {"X-Parse-Application-Id":"assure-parse-app","Content-Type":"application/json"}
	r = requests.post("http://assure-parse.herokuapp.com/parse/classes/ProbeRequests", headers=parse_headers, data = data)
	if r.status_code == 201:
		print("Parse object created")
	else:
		print("Error adding to database")
		print(r.text)
	#return a message.
	return "Thank you for your data."

@app.route('/', methods=['GET'])
def processIncomingGetData():
	print "GET REQUEST"
	return "GET out of town. Get it? Get it."

# run the app!
if __name__ == "__main__":
    app.run(host='0.0.0.0')
