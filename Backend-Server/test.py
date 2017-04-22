import requests, json
parse_headers = {"X-Parse-Application-Id":"assure-parse-app","Content-Type":"application/json"}
data = {"fromMAC":"asdf", "rssi": "rssi" }
data = json.dumps(data)
r = requests.post("http://assure-parse.herokuapp.com/parse/classes/ProbeRequests", headers=parse_headers, data = data)

print(r.text)