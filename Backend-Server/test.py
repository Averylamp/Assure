import requests, json
parse_headers = {"X-Parse-Application-Id":"assure-parse-app","Content-Type":"application/json"}

r = requests.get("http://assure-parse.herokuapp.com/parse/config", headers=parse_headers)
config_results = r.json()["params"]

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
print(config_results)
distances = {}
for mac in config_results.keys():
	mac_address = stringToMAC(mac)
	params = {"where":json.dumps({"fromMAC":mac_address}), "limit": 15, "order":"-createdAt"}
	r = requests.get("http://assure-parse.herokuapp.com/parse/classes/ProbeRequests", headers=parse_headers, params= params)
	parse_results = r.json()["results"]
	# print(parse_results)
	if len(parse_results) == 0:
		distances[mac_address] = 1000
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
print(distances)
min_distance = 10000
min_mac = ""
min_module = 0

for item in distances.items():
	if item[1] < min_distance:
		min_distance = item[1]
		min_mac = item[0]
		min_module = config_results[min_mac.replace(":", "")]

print("Closest Module - {}, Distance - {},     MAC - {}".format(min_module, min_distance, min_mac))
