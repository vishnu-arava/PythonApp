from flask import Flask
from flask_mysqldb import MySQL
from flask_bcrypt import Bcrypt

app = Flask(__name__)
app.secret_key = 'your_secret_key'  # Change this to a random secret key

# Configure MySQL
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'chaitanya_root'
app.config['MYSQL_DB'] = 'flask'

mysql = MySQL(app)
bcrypt = Bcrypt(app)

from flask_auth import routes
