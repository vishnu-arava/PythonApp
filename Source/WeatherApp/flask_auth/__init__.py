from flask import Flask
from flask_mysqldb import MySQL
from flask_bcrypt import Bcrypt
import logging
import os
from azure.identity import ClientSecretCredential
from azure.keyvault.secrets import SecretClient
from dotenv import load_dotenv

app = Flask(__name__)
app.secret_key = 'your_secret_key'  # Change this to a random secret key

# Configure MySQL
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'chaitanya_root'
app.config['MYSQL_DB'] = 'flask'

mysql = MySQL(app)
bcrypt = Bcrypt(app)


# log_dir = os.path.join(os.path.abspath(os.path.dirname(__file__)), '..', 'Logs')
# if not os.path.exists(log_dir):
#     os.makedirs(log_dir)

# # Create a custom logger
# logger = logging.getLogger('my_logger')
# logger.setLevel(logging.DEBUG)  # Set the lowest level to capture all messages

# # Create handlers for different log levels
# debug_handler = logging.FileHandler(os.path.join(log_dir, 'debug.log'))
# info_handler = logging.FileHandler(os.path.join(log_dir, 'info.log'))
# warning_handler = logging.FileHandler(os.path.join(log_dir, 'warning.log'))
# error_handler = logging.FileHandler(os.path.join(log_dir, 'error.log'))
# critical_handler = logging.FileHandler(os.path.join(log_dir, 'critical.log'))

# # Set levels for handlers
# debug_handler.setLevel(logging.DEBUG)
# info_handler.setLevel(logging.INFO)
# warning_handler.setLevel(logging.WARNING)
# error_handler.setLevel(logging.ERROR)
# critical_handler.setLevel(logging.CRITICAL)

# # Create formatters and add them to handlers
# formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# debug_handler.setFormatter(formatter)
# info_handler.setFormatter(formatter)
# warning_handler.setFormatter(formatter)
# error_handler.setFormatter(formatter)
# critical_handler.setFormatter(formatter)

# # Add handlers to the logger
# logger.addHandler(debug_handler)
# logger.addHandler(info_handler)
# logger.addHandler(warning_handler)
# logger.addHandler(error_handler)
# logger.addHandler(critical_handler)

# # Add logger to the Flask app
# app.logger.addHandler(debug_handler)
# app.logger.addHandler(info_handler)
# app.logger.addHandler(warning_handler)
# app.logger.addHandler(error_handler)
# app.logger.addHandler(critical_handler)


def retrieve_secret(secret_name):
    try:
        # Authenticate with Azure AD using ClientSecretCredential
        credential = ClientSecretCredential(
            tenant_id=os.getenv("TENANT_ID"),
            client_id=os.getenv("CLIENT_ID"),
            client_secret=os.getenv("CLIENT_SECRET")
        )

        # Create a SecretClient using the Key Vault URI and the client secret credential
        client = SecretClient(vault_url=os.getenv("KEY_VAULT_URI"), credential=credential)

        # Retrieve a secret by its name
        retrieved_secret = client.get_secret(secret_name)

        if retrieved_secret:
            return retrieved_secret.value
        else:
            return None
    except Exception as e:
        print("Error occurred:", e)
        return None

#Retrieving Values from keyvault
load_dotenv()
secret_name = "DataBaseServerLink"
DataBaseServerLink = retrieve_secret(secret_name)
secret_name = "DataBasePassword"
DataBasePassword = retrieve_secret(secret_name)
secret_name = "DataBaseUserName"
DataBaseUserName = retrieve_secret(secret_name)
secret_name = "DataBaseName"
DataBaseName = retrieve_secret(secret_name)
secret_name = "OpenWeatherApiKey"
OpenWeatherApiKey = retrieve_secret(secret_name)
secret_name = "GEODBApiKey"
GEODBApiKey = retrieve_secret(secret_name)