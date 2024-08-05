from flask import Flask
from flask_bcrypt import Bcrypt
import logging
import os
from azure.identity import ClientSecretCredential
from azure.keyvault.secrets import SecretClient
from dotenv import load_dotenv
import urllib
from flask_sqlalchemy import SQLAlchemy
from azure.servicebus import ServiceBusClient
from datetime import timedelta

app = Flask(__name__)
#app.permanent_session_lifetime = timedelta(minutes=2)




def retrieve_secret(secret_name,credential):
    try:
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
# Authenticate with Azure AD using ClientSecretCredential
credential = ClientSecretCredential(tenant_id=os.getenv("TENANT_ID"),client_id=os.getenv("CLIENT_ID"),client_secret=os.getenv("CLIENT_SECRET"))
secret_name = "DataBaseServerLink"
DataBaseServerLink = retrieve_secret(secret_name,credential)
print(f"Got DataBaseServerLink from key vault:{DataBaseServerLink}")

secret_name = "DataBasePassword"
DataBasePassword = retrieve_secret(secret_name,credential)
print(f"Got DataBasePassword from key vault:{DataBasePassword}")

secret_name = "DataBaseUserName"
DataBaseUserName = retrieve_secret(secret_name,credential)
print(f"Got DataBaseUserName from key vault:{DataBaseUserName}")

secret_name = "DataBaseName"
DataBaseName = retrieve_secret(secret_name,credential)
print(f"Got DataBaseName from key vault:{DataBaseName}")

secret_name = "OpenWeatherApiKey"
OpenWeatherApiKey = retrieve_secret(secret_name,credential)
print(f"Got OpenWeatherApiKey from key vault:{OpenWeatherApiKey}")

secret_name = "GEODBApiKey"
GEODBApiKey = retrieve_secret(secret_name,credential)
print(f"Got GEODBApiKey from key vault:{GEODBApiKey}")

app.config['SECRET_KEY'] = str(os.getenv("SECRET_KEY"))

#service bus connection
servicebus_namespace = 'dkweatherappsb-dev'
queue_name = 'weatherappqueue'
servicebus_client = ServiceBusClient(
    fully_qualified_namespace=servicebus_namespace + '.servicebus.windows.net',
    credential=credential
)

server = str(DataBaseServerLink)
database = str(DataBaseName)
username = str(DataBaseUserName)
password = str(DataBasePassword)
driver = 'ODBC Driver 17 for SQL Server'

# Construct the connection string
params = urllib.parse.quote_plus(
    f'DRIVER={{{driver}}};SERVER={server};DATABASE={database};UID={username};PWD={password}'
)
print(f"Server: {server}")
print(f"Database: {database}")
print(f"Username: {username}")
print(f'Paramsis :{params}')
connection_string = f'mssql+pyodbc:///?odbc_connect={params}'

print(f'Connectionstring is :{connection_string}')
# Configure the SQLAlchemy part of the app instance
app.config['SQLALCHEMY_DATABASE_URI'] = connection_string
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Create the SQLAlchemy db instance
mysql = SQLAlchemy(app)
bcrypt = Bcrypt(app)

from flask_auth import routes