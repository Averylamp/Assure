# Media Lab Design Hackathon
# by Ethan Weber, Avery Lamp, and Kenny Friedman 
# April 21, 2017

#import the main flask, and request (to handle post request parameters) 
from flask import Flask, request
import requests, json, operator
import numpy as np
from datetime import datetime, timedelta
from twilio.rest import Client
#begin a flask app
app = Flask(__name__)

last_values = {}


##########################################################################################
############################### HELPER FUNCTIONS #########################################
##########################################################################################

#posts a dictionary to the parse server on herokuapp
def sendDictionaryToParse(data, class_name):
	data = json.dumps(data)
	parse_headers = {"X-Parse-Application-Id":"assure-parse-app","Content-Type":"application/json"}
	r = requests.post("http://assure-parse.herokuapp.com/parse/classes/" + class_name, headers=parse_headers, data = data)
	if r.status_code == 201:
		print("Parse object created")
	else:
		print("Error adding to database")
		print(r.text)

#returns the difference between now and the datestring
def withinSecondsFromNow(datestring, seconds):
	format_str = "%Y-%m-%dT%H:%M:%S"
	datetime_obj = datetime.strptime(datestring, format_str)
#	datetime_obj = datetime_obj + timedelta(hours=0)
	now = datetime.now()
	difference = now - datetime_obj
#	print("Difference seconds = {}".format(difference.total_seconds()))
	return difference.total_seconds() < seconds

##########################################################################################
############################### HANDLING REQUESTS ########################################
##########################################################################################

#Handle post requests from the root directory
@app.route('/', methods=['POST'])
def processIncomingPostData():
	if request.values.get("from_mac") is None or request.values.get("rssi") is None:
		print("invalid params")
		return "No valid parameters"
	devices = {'A0:20:A6:0F:26:15': '2', 'A0:20:A6:01:56:52': '4', 'A0:20:A6:0F:28:9B': '1', 'A0:20:A6:01:53:54': '3', 'A0:20:A6:0F:29:0F': '5', 'A0:20:A6:01:56:B8':'6', 'A0:20:A6:04:62:4A':'7', 'A0:20:A6:07:14:F4':'8'}

	data = {}
	data["fromMAC"] =  request.values.get("from_mac")
	device = request.values.get("device")
	rssi =  request.values.get("rssi")
	data["rssi"] = rssi
	data["distance"] = str(10 ** ((-45 - int(rssi)) / 20.0))
	print("Request recieved from - {}, distance - {},  rssi - {}".format(devices[data["fromMAC"]], data["distance"], data["rssi"]))
	if request.values.get("rssi") == "0":
		print("NO RESPONSE RECIEVED FROM DEVICE - {}".format(devices[data["fromMAC"]]))
		return "No recent Probe requests"
	print("Distance - {}".format(data["distance"]))

	global last_values
	if data["fromMAC"] in last_values:
		mean = np.mean(last_values[data["fromMAC"]])
		std = np.std(last_values[data["fromMAC"]]) + 10
		scale = max(1, mean / 20)
		std = std * scale
		print("Mean - {}, Std -{}, Expected range - {}, {}".format(mean, std, mean - std, mean + std))
		next_distance = float(data["distance"])
		if abs(next_distance - mean) > std:
			if next_distance > mean:
				next_distance = mean + std
			else:
				next_distance = mean - std
			print("Modified distance - {}".format(next_distance))
		if len(last_values[data["fromMAC"]]) >= 10:
			last_values[data["fromMAC"]] =  last_values[data["fromMAC"]][1:] + [next_distance]
		data["distance"] = str(next_distance)
	else:
		last_values[data["fromMAC"]] = [float(data["distance"])]
	sendDictionaryToParse(data, "ProbeRequests")
	#return a message.
	return "Thank you for your data."

@app.route('/', methods=['GET'])
def processIncomingGetData():
	print "GET REQUEST"
	return "GET Requests Currently Do Not Serve A Purpose"

last_app_response = datetime.now()

@app.route('/closestTeensy/', methods=['GET'])
def getClosestTeensy():
	closest_module = getClosestModule()
	returnVal = closest_module[0]
	if returnVal == "N":
		returnVal = "0"
	global	last_app_response
	now = datetime.now()
	diff_dates = now - last_app_response
	invalid_interval = 35
	if diff_dates.total_seconds() > invalid_interval:
		returnVal += "N"
	else:
		returnVal += "Y"
	print("Last alert response - {} seconds ago".format(diff_dates.total_seconds()))

	print("<html>" + returnVal + "</html>")
	return "<html>" + returnVal + "</html>"

@app.route('/positiveResponse/', methods=['GET'])
def handlePositiveResponse():
	global last_app_response
	last_app_response = datetime.now()
	return "Positive response OK"

@app.route('/closestModule/', methods=['GET'])
def getClosestModule():
	parse_headers = {"X-Parse-Application-Id":"assure-parse-app","Content-Type":"application/json"}
	r = requests.get("http://assure-parse.herokuapp.com/parse/config", headers=parse_headers)
	config_results = r.json()["params"]
	date_query = ""
	# from_date = "%Y-%m-%dT%H:%M:%S.000Z"
	if request.values.get("from_date") is None:
		format_str = "%Y-%m-%dT%H:%M:%S.000Z"
		datetime_obj = datetime.now()
	#	datetime_obj = datetime_obj + timedelta(hours=4)
		date_query = datetime_obj.strftime(format_str)
	else:
		date_query = request.values.get("from_date")
#	print("Date - {}".format(date_query))
	total_seconds_max = 120

	def stringToMAC(string_in):
		config_results = ""
		count = 0
		for i in string_in:
			if count == 2:
				config_results += ":"
				count = 0
			count += 1
			config_results += i
		return config_results
	# print(config_results)
	distances = {}
	for mac in config_results.keys():
		mac_address = stringToMAC(mac)
		params = {"where":json.dumps({"fromMAC":mac_address,"createdAt":{"$lte":{"__type":"Date","iso":date_query}}}), "limit": 5, "order":"-createdAt"}
		r = requests.get("http://assure-parse.herokuapp.com/parse/classes/ProbeRequests", headers=parse_headers, params= params)
		# print(r.text)
		parse_results = r.json()["results"]
		print("Number of results - {}".format(len(parse_results)))
		filtered_results = []
		for i in parse_results:
			if withinSecondsFromNow(i["createdAt"][:-5], total_seconds_max):
				filtered_results.append(i)
			else:
				continue
		parse_results = filtered_results
		print("Number of filtered results - {}".format(len(parse_results)))
		if len(parse_results) == 0:
			distances[mac_address] = 1000
			continue
		print(parse_results[0]["createdAt"])
		mid = 1.0 / len(parse_results)
		median = float(len(parse_results) / 2)
		if median == 0 :
			median = 1
		distance = 0
		# print(parse_config_resultss)
		for i in range(len(parse_results)):
			next_add = float(parse_results[i]["distance"])
			# next_add = 1
			next_weight = ((((median - i) / median) * mid) + mid)
			distance += next_add * next_weight
		print("Module - {},  Mac - {}, Distance - {}".format(config_results[mac], mac_address, distance))
		distances[mac_address] = distance
		# print(config_results)
	# print(distances)
	min_distance = 10000
	min_mac = ""
	min_module = 0
	sorted_dist = sorted(distances.items(), key=operator.itemgetter(1))
	distances = []
	for i in sorted_dist:
		distances.append((config_results[i[0].replace(":","")], i[1]))
	#for item in distances.items():
	#	if item[1] < min_distance:
#			min_distance = item[1]
#			min_mac = item[0]
#			min_module = config_results[min_mac.replace(":", "")]
	if distances[0][1] == 1000:
#	if min_distance == 1000:
		print("No closest module")
		return "No closest module"
#	print("Closest Module - {}, Distance - {},     MAC - {}".format(min_module, min_distance, min_mac))
	print("\n".join(", distance - ".join(map(str,sl)) for sl in distances))
	return ",".join(",".join(map(str,sl)) for sl in distances)


@app.route('/sendText/', methods=['GET','POST'])
def send_message(text):
	print("------------------------------")
	print("Send text initiated")
	if request.values.get("message") is None:
		return "No message sent"
	elif text is None:
		text = request.values.get("message")
	account_sid = "AC8297f68c93c5374aec9089e8fabfc089"
	auth_token = "118545b140865a4db481070ed8092699"
	client = Client(account_sid, auth_token)

#	numbers = ["+19202860426", "+19738738225"]
	numbers = ["+19738738225","+19202860426","+16268727820","+13233948643","+13153833921"]
	for i in numbers:
		message = client.api.account.messages.create(to=i,from_="+16265514837",body=text)
		print(message.sid)
		print("Sent Message")
	return "Success, sent messages"

# Code for sending a fall-request
@app.route('/fall/', methods=['GET', 'POST'])
def fallOccured():
	print("A FALL HAS OCCURED.")
	if request.values.get("message") is None:
		return "No message sent"
	else:
		text = request.values.get("message")
		locations = {"2":"Bathroom","4":"Bedroom", "5":"Kitchen", "6":"Living Room"}
		data = {}
		data["dismissed"] = False
		data["viewed"] = False
		data["personName"] = "Grandpa"
		location = ""
		last_module = getClosestModule()[0]
		if last_module in locations:
			location += " in the " + locations[last_module]
		data["alertMessage"] = "A fall was just detected" + location + ".  Grandpa may need help."
		data["positiveResponse"] = "On my way!"
		send_message(data["alertMessage"])
		sendDictionaryToParse(data, "Alerts")

	return "Oh no!"

@app.route('/lifeAlert/', methods=['GET', 'POST'])
def lifeAlertOccured():
	print("A FALL HAS OCCURED.")
	if request.values.get("message") is None:
		return "No message sent"
	else:
		locations = {"2":"Bathroom","4":"Bedroom", "5":"Kitchen", "6":"Living Room"}
		text = request.values.get("message")
		data = {}
		data["dismissed"] = False
		data["viewed"] = False
		data["personName"] = "Grandpa"
		location = ""
		last_module = getClosestModule()[0]
		if last_module in locations:
			location += "  He is in the " + locations[last_module]
		data["alertMessage"] = "Grandpa just pushed the life alert button." + location
		send_message(data["alertMessage"])
		data["positiveResponse"] = "On my way!"
		sendDictionaryToParse(data, "Alerts")
	return "Oh no!"

state = "NONE"


@app.route('/get-location/', methods=['GET', 'POST'])
def getLocation():
	print("An app is requesting location")
	return "Here's the location: kitchen"

# run the app!
if __name__ == "__main__":
    app.run(host='0.0.0.0', threaded=True)
