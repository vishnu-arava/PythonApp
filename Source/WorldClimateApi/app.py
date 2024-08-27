from flask import Flask, request, jsonify, render_template
import json
import requests
from os import environ
import os
from dotenv import load_dotenv
app = Flask(__name__)

def get_states(country_name):
    url = "https://countriesnow.space/api/v0.1/countries/states"
    response = requests.post(url, json={"country": country_name})
    if response.status_code == 200:
        data = response.json()
        country_code = data.get('data',{}).get('iso2','')
        states = data.get('data', {}).get('states', [])
        return ([state['name'] for state in states],country_code)
    else:
        return f"Error: {response.status_code}"

stateNameconcat = lambda statename : '+'.join(statename.split(" "))

def states_weather(stateslist,country_code,apikey):
    statesList=[]
    for i in stateslist:
        statename = stateNameconcat(i)
        uri=f"https://api.openweathermap.org/data/2.5/weather?q={statename},{country_code}&appid={apikey}"
        response = requests.get(uri).json()
        if response['cod'] == 200:
            statereportDict = {
                'statename' : i,
                'temperaturemin':(response['main'])['temp_min'],
                'temperaturemax':(response['main'])['temp_max'],
                'humidity':(response['main'])['humidity'],
                'windspeed':(response['wind'])['speed'],
                'winddirection':(response['wind'])['deg'],
                'weatherdescription':(response['weather'])[0]['description']
            }
            statesList.append(statereportDict)
    return (statesList)


@app.route('/country',methods=['GET'])
def cityStates():
    countryName = request.args.get('countryname')
    apikey = request.args.get('apikey')
    states,states_code = get_states(countryName)
    slist = states_weather(states,states_code,apikey)
    data={
        'count':len(slist),
        'value':slist
    }
    response_data = json.dumps(data)
    return jsonify(response_data)

@app.route('/env',methods=['POST','GET'])
def envVariables():
    load_dotenv()
    envVar=os.getenv("testenv")
    return render_template('env.html',envVal=envVar)

if __name__ == '__main__':
    app.run(host='0.0.0.0',port=8000)