from flask import render_template, redirect, url_for, flash, session,request
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
@app.route('/')
def home():
    return render_template('home.html')


@app.route('/register', methods=['GET', 'POST'])
def register():
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
        return redirect(url_for('login'))

    return render_template('register.html', form=form)


@app.route('/login', methods=['GET', 'POST'])
def login():
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
            return redirect(url_for('dashboard'))
        else:
            flash('Login Unsuccessful. Please check username and password', 'danger')

    return render_template('login.html', form=form)


@app.route('/dashboard')
def dashboard():
    #if 'username' not in session:
    #    flash('You are not logged in!', 'warning')
    #    return redirect(url_for('login'))

    #return f'Welcome to your dashboard, {session["username"]}! <a href="/logout">Logout</a>'
    if 'username' in session:
        return render_template('dashboard.html')

@app.route('/logout')
def logout():
    session.pop('username', None)
    flash('You have been logged out.', 'info')
    return redirect(url_for('login'))



@app.route('/page1',methods=['POST','GET'])
def weather():
    api_key = '48a90ac42caa09f90dcaeee4096b9e53'
    if request.method == 'POST':
        city = request.form['city']
    else:
        #for default name mathura
        city = 'mathura'

    # source contain json data from api
    try:
        source = urllib.request.urlopen('http://api.openweathermap.org/data/2.5/weather?q=' + city + '&appid='+api_key).read()
    except:
        return abort(404)
    # converting json data to dictionary

    list_of_data = json.loads(source)

    # data for variable list_of_data
    data = {
        "country_code": str(list_of_data['sys']['country']),
        "coordinate": str(list_of_data['coord']['lon']) + ' ' + str(list_of_data['coord']['lat']),
        "temp": str(list_of_data['main']['temp']) + 'k',
        "temp_cel": tocelcius(list_of_data['main']['temp']) + 'C',
        "pressure": str(list_of_data['main']['pressure']),
        "humidity": str(list_of_data['main']['humidity']),
        "cityname":str(city),
    }
    return render_template('page1.html',data=data)
#@app.route('/page2')
#def page2():
#    return render_template('page2.html')
@app.route('/page2',methods=['POST','GET'])
def weather1():
    api_key = '48a90ac42caa09f90dcaeee4096b9e53'
    if request.method == 'POST':
        city = request.form['city']
    else:
        #for default name mathura
        city = 'mathura'

    # source contain json data from api
    try:
        source = urllib.request.urlopen('http://api.openweathermap.org/data/2.5/weather?q=' + city + '&appid='+api_key).read()
    except:
        return abort(404)
    # converting json data to dictionary

    list_of_data = json.loads(source)

    # data for variable list_of_data
    data = {
        "country_code": str(list_of_data['sys']['country']),
        "coordinate": str(list_of_data['coord']['lon']) + ' ' + str(list_of_data['coord']['lat']),
        "temp": str(list_of_data['main']['temp']) + 'k',
        "temp_cel": tocelcius(list_of_data['main']['temp']) + 'C',
        "pressure": str(list_of_data['main']['pressure']),
        "humidity": str(list_of_data['main']['humidity']),
        "cityname":str(city),
    }
    return render_template('page2.html',data=data)
@app.route('/predict',methods=['POST','GET'])
def predict():
    if not os.path.isfile('model.pkl'):
        filename = 'https://github.com/nachi-hebbar/Forest-Fire-Prediction-Website/blob/master/Forest_fire.csv'
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
