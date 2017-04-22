import requests, json
from datetime import datetime




# def to_datetime(datestring):
# 	format_str = "%Y-%m-%dT%H:%M:%S"
# 	datetime_obj = datetime.strptime(datestring, format_str)
# 	datetime_obj = datetime_obj.replace(hour = datetime_obj.hour - 4)
# 	return	datetime_obj

# s = '2017-04-22T17:03:07.615Z'
# print(s[:-5])
# print(to_datetime(s[:-5]))
# ind = to_datetime(s[:-5])
# now = datetime.now()
# print(datetime.now())
# difference = (now - ind)
# print(difference)
# print(difference.total_seconds())





def withinSecondsFromNow(datestring, seconds):
	format_str = "%Y-%m-%dT%H:%M:%S"
	datetime_obj = datetime.strptime(datestring, format_str)
	datetime_obj = datetime_obj.replace(hour = datetime_obj.hour - 4)
	now = datetime.now()
	difference = now - datetime_obj

	return difference.total_seconds() < seconds

def getClosestModule():
	parse_headers = {"X-Parse-Application-Id":"assure-parse-app","Content-Type":"application/json"}
	r = requests.get("http://assure-parse.herokuapp.com/parse/config", headers=parse_headers)
	config_results = r.json()["params"]

	date_query = ""
	if request.values.get("from_date") is None:
		format_str = "%Y-%m-%dT%H:%M:%S.000Z"
		datetime_obj = datetime.now()
		datetime_obj = datetime_obj.replace(hour = datetime_obj.hour + 4)
		date_query = datetime_obj.strftime(format_str)
	else:
		date_query = request.values.get("from_date")

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
		params = {"where":json.dumps({"fromMAC":mac_address,"createdAt":{"$lte":{"__type":"Date","iso":"2017-04-22T16:12:26.398Z"}}}), "limit": 25, "order":"-createdAt"}
		r = requests.get("http://assure-parse.herokuapp.com/parse/classes/ProbeRequests", headers=parse_headers, params= params)
		# print(r.text)
		parse_results = r.json()["results"]
		
		filtered_results = []
		for i in parse_results:
			if withinSecondsFromNow(i["createdAt"][:-5], total_seconds_max):
				filtered_results.append(i)
			else:
				continue
		parse_results = filtered_results
		if len(parse_results) == 0:
			distances[mac_address] = 1000
			continue
		print(parse_results[0]["createdAt"])
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

	if min_distance == 1000:
		print("No closest module")
		return "No closest module"
	print("Closest Module - {}, Distance - {},     MAC - {}".format(min_module, min_distance, min_mac))
	return "Closest Module - {}, Distance - {},     MAC - {}".format(min_module, min_distance, min_mac)
getClosestModule()

# parse_headers = {"X-Parse-Application-Id":"assure-parse-app","Content-Type":"application/json"}

# r = requests.get("http://assure-parse.herokuapp.com/parse/config", headers=parse_headers)
# config_results = r.json()["params"]

# def stringToMAC(string_in):
# 	config_results = ""
# 	count = 0
# 	for i in string_in:
# 		if count == 2:
# 			config_results += ":"
# 			count = 0
# 		count += 1
# 		config_results += i
# 	return config_results
# print(config_results)
# distances = {}
# for mac in config_results.keys():
# 	mac_address = stringToMAC(mac)
# 	params = {"where":json.dumps({"fromMAC":mac_address}), "limit": 15, "order":"-createdAt"}
# 	r = requests.get("http://assure-parse.herokuapp.com/parse/classes/ProbeRequests", headers=parse_headers, params= params)
# 	parse_results = r.json()["results"]
# 	print(parse_results)
# 	if len(parse_results) == 0:
# 		distances[mac_address] = 1000
# 		continue
# 	mid = 1.0 / len(parse_results)
# 	median = float(len(parse_results) / 2)
# 	distance = 0
# 	# print(parse_config_resultss)
# 	for i in range(len(parse_results)):
# 		next_add = float(parse_results[i]["distance"])
# 		# next_add = 1
# 		next_weight = ((((median - i) / median) * mid) + mid)
# 		distance += next_add * next_weight
# 	print("Module - {},  Mac - {}, Distance - {}".format(config_results[mac], mac_address, distance))
# 	distances[mac_address] = distance
# 	# print(config_results)
# print(distances)
# min_distance = 10000
# min_mac = ""
# min_module = 0

# for item in distances.items():
# 	if item[1] < min_distance:
# 		min_distance = item[1]
# 		min_mac = item[0]
# 		min_module = config_results[min_mac.replace(":", "")]

# print("Closest Module - {}, Distance - {},     MAC - {}".format(min_module, min_distance, min_mac))
