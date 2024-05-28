from flask import render_template, redirect, url_for, flash, session,jsonify
import requests
from flask_auth import app, mysql, bcrypt
from flask_auth.forms import RegistrationForm, LoginForm
import urllib.request
from flask import (request)
import json
import pickle
import numpy as np
import pandas as pd
import os
import warnings
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
import logging
from logging.handlers import RotatingFileHandler
from datetime import datetime

formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
file_handler = RotatingFileHandler('Logfiles/app.log', maxBytes=1024 * 1024 * 10, backupCount=5)
file_handler.setFormatter(formatter)
app.logger.addHandler(file_handler)
app.logger.setLevel(logging.DEBUG)

weather_description_code = {
        '0': "Clear sky",
        '1': "Mainly clear",
        '2': "Partly cloudy",
        '3': "Overcast",
        '45': "Fog",
        '48': "Depositing rime fog",
        '51': "Light drizzle",
        '53': "Moderate drizzle",
        '55': "Dense drizzle",
        '56': "Light freezing drizzle",
        '57': "Dense freezing drizzle",
        '61': "Slight rain",
        '63': "Moderate rain",
        '65': "Heavy rain",
        '66': "Light freezing rain",
        '67': "Heavy freezing rain",
        '71': "Slight snow fall",
        '73': "Moderate snow fall",
        '75': "Heavy snow fall",
        '77': "Snow grains",
        '80': "Slight rain showers",
        '81': "Moderate rain showers",
        '82': "Violent rain showers",
        '85': "Slight snow showers",
        '86': "Heavy snow showers",
        '95': "Thunderstorm",
        '96': "Thunderstorm with slight hail",
        '99': "Thunderstorm with heavy hail"
    }
GEODB_API_KEY = '03b7c4734dmsha8ae33637250f48p11c63fjsn48372cbe71f6'
def get_cities():

    url = "https://wft-geo-db.p.rapidapi.com/v1/geo/cities"
    headers = {
        "X-RapidAPI-Key": GEODB_API_KEY,
        "X-RapidAPI-Host": "wft-geo-db.p.rapidapi.com"
    }
    response = requests.get(url, headers=headers, params={"limit": 10})
    data = response.json()
    cities = [city['name'] for city in data['data']]
    return cities

def tocelcius(temp):
    return str(round(float(temp) - 273.16,2))

def get_coordinates(city_name):
    api_key = '48a90ac42caa09f90dcaeee4096b9e53'
    source = urllib.request.urlopen(
        'http://api.openweathermap.org/data/2.5/weather?q=' + city_name + '&appid=' + api_key).read()
    list_of_data = json.loads(source)
    return float(list_of_data['coord']['lat']), float(list_of_data['coord']['lon'])

def get_weather(latitude, longitude):
    url = f'https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,relative_humidity_2m_max,wind_speed_10m_max,windspeed_10m_min,winddirection_10m_dominant,relative_humidity_2m_min,weathercode&timezone=GMT'
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error: Unable to fetch data (status code {response.status_code})")
        return None

def get_city_weather(city_name):
    latitude, longitude = get_coordinates(city_name)
    if latitude and longitude:
        weather_data = get_weather(latitude, longitude)
        return weather_data
    else:
        return None

def get_matching_cities(query):
    # List of cities (you might want to fetch this from a database or external API)
    cities = ["Hyderabad", "London", "New York", "Los Angeles", "Paris", "Tokyo", "Sydney"]

    # Filter cities based on the query
    matching_cities = [city for city in cities if query.lower() in city.lower()]

    return matching_cities


@app.route('/')
def home():
    app.logger.info('Loading the home page')
    return render_template('home.html')


@app.route('/register', methods=['GET', 'POST'])
def register():
    app.logger.info('Loading the register page')
    form = RegistrationForm()
    if form.validate_on_submit():
        username = form.username.data
        email = form.email.data
        password = bcrypt.generate_password_hash(form.password.data).decode('utf-8')

        cursor = mysql.connection.cursor()
        cursor.execute('INSERT INTO users (username, email, password) VALUES (%s, %s, %s)', (username, email, password))
        mysql.connection.commit()
        cursor.close()

        flash('You have successfully registered!', 'success')
        app.logger.info(f'user:{username} account has been created')
        return redirect(url_for('login'))

    return render_template('register.html', form=form)


@app.route('/login', methods=['GET', 'POST'])
def login():
    app.logger.info('Loading the login page')
    form = LoginForm()
    if form.validate_on_submit():
        username = form.username.data
        password = form.password.data

        cursor = mysql.connection.cursor()
        cursor.execute('SELECT * FROM users WHERE username = %s', [username])
        user = cursor.fetchone()
        cursor.close()

        if user and bcrypt.check_password_hash(user[3], password):  # user[3] is the password field
            session['username'] = user[1]  # user[1] is the username field
            flash('Login successful!', 'success')
            app.logger.info(f'user:{username} has logged in successfully')
            return redirect(url_for('dashboard'))
        else:
            app.logger.warning('Wrong credentials have been used for login')
            flash('Login Unsuccessful. Please check username and password', 'danger')

    return render_template('login.html', form=form)

@app.route('/dashboard')
def dashboard():
    app.logger.info('Loading the dashboard')
    if 'username' in session:
        return render_template('dashboard.html')

@app.route('/logout')
def logout():
    session.pop('username', None)
    app.logger.info(f'the user has logged out')
    flash('You have been logged out.', 'info')
    return redirect(url_for('login'))



@app.route('/page1',methods=['POST','GET'])
def weather():
    app.logger.info('Loading the weather search page')
    emptdict = {}
    weekly_weather_list = []

    if request.method == 'POST':
        city = request.form['city']
        print(city)
    else:
        city = 'hyderabad'
    if not city:
        app.logger.warning('No city has been provided for the search')
    else:
        app.logger.info(f'The city : {city} was given for the search')
    try:
        city_name = city
        weather_data = get_city_weather(city_name)
        dict = weather_data['daily']
        for i in range(0, len(dict['time'])):
            emptdict['cityname'] = city_name
            emptdict['date'] = dict['time'][i]
            date_object = datetime.strptime(emptdict['date'], '%Y-%m-%d')
            emptdict['day'] = str(date_object.strftime('%A'))
            emptdict['temperature_min'] = str(dict['temperature_2m_min'][i])
            emptdict['temperature_max'] = str(dict['temperature_2m_max'][i])
            emptdict['precipitation'] = str(dict['precipitation_sum'][i])
            emptdict['humidity_min'] = str(dict['relative_humidity_2m_min'][i])
            emptdict['humidity_max'] = str(dict['relative_humidity_2m_max'][i])
            emptdict['windspeed_min'] = str(dict['windspeed_10m_min'][i])
            emptdict['windspeed_max'] = str(dict['wind_speed_10m_max'][i])
            emptdict['windirection'] = str(dict['winddirection_10m_dominant'][i])
            emptdict['weather_code'] = str(weather_description_code[str(dict['weathercode'][i])])
            weekly_weather_list.append(emptdict)
            emptdict = {}
        print(weekly_weather_list)
    except:
        return render_template('page1.html', maindata=[{
            'cityname': '',
            'date': '',
            'day':'',
            'temperature_min':'',
            'temperature_max':'',
            'humidity_min':'',
            'humidity_max':'',
            'windspeed_min':'',
            'windspeed_max':'',
            'windirection':'',
            'weather_code':''
        },{
            'cityname': '',
            'date': '',
            'day':'',
            'temperature_min':'',
            'temperature_max':'',
            'humidity_min':'',
            'humidity_max':'',
            'windspeed_min':'',
            'windspeed_max':'',
            'windirection':'',
            'weather_code':''
        }])
    return render_template('page1.html', maindata=weekly_weather_list)
@app.route('/search', methods=['POST'])
def search():
    query = request.form['query']
    # Assuming you have a function get_matching_cities(query) that returns a list of matching cities
    matching_cities = get_matching_cities(query)
    # Return the list of matching cities as JSON
    return jsonify(matching_cities)
@app.route('/predict',methods=['POST','GET'])
def predict():
   if not os.path.isfile('model.pkl'):
       filename = 'flask_auth\Forest_fire.csv'
       filepath = os.path.abspath(filename)
       data = pd.read_csv(filepath)
       data = np.array(data)
       X = data[1:, 1:-1]
       y = data[1:, -1]
       y = y.astype('int')
       X = X.astype('int')
       # print(X,y)
       X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=0)
       log_reg = LogisticRegression()
       log_reg.fit(X_train, y_train)
       inputt = [int(x) for x in "45 32 60".split(' ')]
       final = [np.array(inputt)]
       b = log_reg.predict_proba(final)
       pickle.dump(log_reg, open('model.pkl', 'wb'))
   model = pickle.load(open('model.pkl', 'rb'))
   int_features=[int(x) for x in request.form.values()]
   final=[np.array(int_features)]
   print(int_features)
   print(final)
   prediction=model.predict_proba(final)
   output='{0:.{1}f}'.format(prediction[0][1], 2)
   if output>str(0.5):
       return render_template('forest_fire.html',pred='Your Forest is in Danger.\nProbability of fire occuring is {}'.format(output),bhai="kuch karna hain iska ab?")
   else:
       return render_template('forest_fire.html',pred='Your Forest is safe.\n Probability of fire occuring is {}'.format(output),bhai="Your Forest is Safe for now")
