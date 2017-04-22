# Media Lab Design Hackathon
# by Ethan Weber, Avery Lamp, and Kenny Friedman 
# April 21, 2017

#import the main flask, and request (to handle post request parameters) 
from flask import Flask, request
import requests, json
import numpy as np
#begin a flask app
app = Flask(__name__)

last_values = {}

#Handle post requests from the root directory
@app.route('/', methods=['POST'])
def processIncomingPostData():
	#ask for data by calling request.values.get("PARAMETER_NAME")
	# print request.values.get("from_mac")
	# print request.values.get("device")
	# print request.values.get("rssi")
	if request.values.get("from_mac") is None:
		print("invalid params")
		return "No valid parameters"
	devices = {'A0:20:A6:0F:26:15': '2', 'A0:20:A6:01:56:52': '4', 'A0:20:A6:0F:28:9B': '1', 'A0:20:A6:01:53:54': '3', 'A0:20:A6:0F:29:0F': '5'}

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
		std = np.std(last_values[data["fromMAC"]]) + 5
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

def withinSecondsFromNow(datestring, seconds):
	format_str = "%Y-%m-%dT%H:%M:%S"
	datetime_obj = datetime.strptime(datestring, format_str)
	datetime_obj = datetime_obj.replace(hour = datetime_obj.hour - 4)
	now = datetime.now()
	difference = now - datetime_obj

	return difference.total_seconds() < seconds

@app.route('/closestModule', methods=['GET'])
def getClosestModule():
	parse_headers = {"X-Parse-Application-Id":"assure-parse-app","Content-Type":"application/json"}
	r = requests.get("http://assure-parse.herokuapp.com/parse/config", headers=parse_headers)
	config_results = r.json()["params"]

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
		params = {"where":json.dumps({"fromMAC":mac_address}), "limit": 25, "order":"-createdAt"}
		r = requests.get("http://assure-parse.herokuapp.com/parse/classes/ProbeRequests", headers=parse_headers, params= params)
		parse_results = r.json()["results"]
		if len(parse_results) == 0:
			distances[mac_address] = 1000
			continue
		filtered_results = []
		for i in parse_results:
			if withinSecondsFromNow(i["createdAt"][:-5], total_seconds_max):
				filtered_results.append(i)
			else:
				continue
		mid = 1.0 / len(parse_results)
		median = float(len(parse_results) / 2)
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

	for item in distances.items():
		if item[1] < min_distance:
			min_distance = item[1]
			min_mac = item[0]
			min_module = config_results[min_mac.replace(":", "")]

	print("Closest Module - {}, Distance - {},     MAC - {}".format(min_module, min_distance, min_mac))

	return "Closest Module - {}, Distance - {},     MAC - {}".format(min_module, min_distance, min_mac)

# run the app!
if __name__ == "__main__":
    app.run(host='0.0.0.0')
