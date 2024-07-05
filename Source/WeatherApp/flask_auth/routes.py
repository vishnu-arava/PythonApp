from flask import render_template, redirect, url_for, flash, session,jsonify
import requests
from flask_auth import mysql, bcrypt, app 
from flask_auth import GEODBApiKey as GEODB_API_KEY, OpenWeatherApiKey as api_key_OW
from flask_auth.forms import RegistrationForm, LoginForm
import urllib.request
from flask import (request)
import json
import pickle
import numpy as np
import pandas as pd
import os
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
import logging
from logging.handlers import RotatingFileHandler
from datetime import datetime
from flask_login import LoginManager, UserMixin, login_user, current_user, logout_user, login_required

# Create a logger for the app
app_logger = logging.getLogger('app_logger')
app_logger.setLevel(logging.DEBUG)

# Handler for logging info and above messages
info_handler = RotatingFileHandler('Logs/info.log', maxBytes=1024 * 1024 * 10, backupCount=5)
info_handler.setLevel(logging.INFO)
info_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))

# Handler for logging error and above messages
error_handler = RotatingFileHandler('Logs/error.log', maxBytes=1024 * 1024 * 10, backupCount=5)
error_handler.setLevel(logging.ERROR)
error_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))

# Add handlers to the logger
app_logger.addHandler(info_handler)
app_logger.addHandler(error_handler)

app.logger = app_logger

class User(mysql.Model, UserMixin):
    __tablename__ = 'users'  # Ensure the model matches the existing table name
    id = mysql.Column(mysql.Integer, primary_key=True)
    username = mysql.Column(mysql.String(20), unique=True, nullable=False)
    email = mysql.Column(mysql.String(120), unique=True, nullable=False)
    password = mysql.Column(mysql.String(60), nullable=False)

    def __repr__(self):
        return f"User('{self.username}', '{self.email}')"

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
    source = urllib.request.urlopen(
        'https://api.openweathermap.org/data/2.5/weather?q=' + city_name + '&appid=' + api_key_OW).read()
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
    cities = ["Hyderabad", "London", "New York", "Los Angeles", "Paris", "Tokyo", "Sydney"]
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

        user = User(username=form.username.data, email=form.email.data, password=password)
        mysql.session.add(user)
        mysql.session.commit()

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

        user = User.query.filter_by(username=form.username.data).first()
     
        if user and bcrypt.check_password_hash(user.password, password):
            session['username'] = user.username
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

@app.route('/weather_search',methods=['POST','GET'])
def weather():
    app.logger.info('Loading the weather search page')
    emptdict = {}
    weekly_weather_list = []

    if request.method == 'POST':
        city = request.form['city']
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
    except:
        return render_template('weather_search.html', maindata=[{
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
    return render_template('weather_search.html', maindata=weekly_weather_list)

@app.route('/weather', methods=['GET'])
def weather_data():
    day = request.args.get('day')
    city = request.args.get('city', 'hyderabad')  # Default to 'hyderabad' if no city is provided
    if not day:
        return jsonify({'error': 'No day provided'}), 400
    app.logger.info(f'Received request for weather data for day: {day} in city: {city}')
    weather_data = get_city_weather(city)
    dict = weather_data['daily']
    for i in range(0, len(dict['time'])):
        date_object = datetime.strptime(dict['time'][i], '%Y-%m-%d')
        if str(date_object.strftime('%A')) == day:
            result = {
                'cityname': city,
                'date': dict['time'][i],
                'day': day,
                'temperature_min': str(dict['temperature_2m_min'][i]),
                'temperature_max': str(dict['temperature_2m_max'][i]),
                'precipitation': str(dict['precipitation_sum'][i]),
                'humidity_min': str(dict['relative_humidity_2m_min'][i]),
                'humidity_max': str(dict['relative_humidity_2m_max'][i]),
                'windspeed_min': str(dict['windspeed_10m_min'][i]),
                'windspeed_max': str(dict['wind_speed_10m_max'][i]),
                'windirection': str(dict['winddirection_10m_dominant'][i]),
                'weather_code': str(weather_description_code[str(dict['weathercode'][i])])
            }
            app.logger.info(f'Returning data: {result}')
            return jsonify(result)
    return jsonify({'error': 'Weather data for the requested day not found'}), 404

@app.route('/search', methods=['POST'])
def search():
    query = request.form['query']
    matching_cities = get_matching_cities(query)
    return jsonify(matching_cities)

@app.route('/weather_predict')
def predic_page():
    return render_template("weather_predict.html")

@app.route('/predict',methods=['POST','GET'])
def predict():
   if not os.path.isfile('model.pkl'):
       filename = r'\Forest_fire.csv'
       filepath = os.path.abspath(filename)
       data = pd.read_csv(filepath)
       data = np.array(data)
       X = data[1:, 1:-1]
       y = data[1:, -1]
       y = y.astype('int')
       X = X.astype('int')
       X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=0)
       log_reg = LogisticRegression()
       log_reg.fit(X_train, y_train)
       pickle.dump(log_reg, open('model.pkl', 'wb'))
   model = pickle.load(open('model.pkl', 'rb'))
   if request.method == 'POST':
       if request.form.values():
           int_features=[int(x) for x in request.form.values() if x.strip()]
           final=[np.array(int_features)]
           if not int_features or (len(int_features)<2):
               return render_template('weather_predict.html', pred='Enter Valid Details')
           prediction=model.predict_proba(final)
           positive_probability = prediction[0][1] * 100
           output = '{:.2f}%'.format(positive_probability)
           if output>str(70):
               return render_template('weather_predict.html',pred='Your Forest is in Danger.\nProbability of fire occuring is {}'.format(output))
           else:
               return render_template('weather_predict.html',pred='Your Forest is safe.\n Probability of fire occuring is {}'.format(output))