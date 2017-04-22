# Media Lab Design Hackathon
# by Ethan Weber, Avery Lamp, and Kenny Friedman 
# April 21, 2017

#import the main flask, and request (to handle post request parameters) 
from flask import Flask, request
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
	#return a message.
	return "Thank you for your data."

@app.route('/', methods=['GET'])
def processIncomingGetData():
	print "GET REQUEST"
	return "GET out of town. Get it? Get it."

# run the app!
if __name__ == "__main__":
    app.run(host='0.0.0.0')