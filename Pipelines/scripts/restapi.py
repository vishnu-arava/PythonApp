import requests
import json

headers = {"content-type": "application/json"}
payload = json.dumps({ "name": "Apple Iphones Pro model1", "data": { "color": "white", "generation": "13pro", "price": 165}})
requestUrl = "https://api.restful-api.dev/objects"
r = requests.post(requestUrl, data=payload, headers=headers)
print(r.content)