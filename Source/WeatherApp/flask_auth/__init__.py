from flask import Flask
from flask_bcrypt import Bcrypt
import logging
import os
from azure.identity import ClientSecretCredential
from azure.keyvault.secrets import SecretClient
from dotenv import load_dotenv
import urllib
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)





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
print("Got DataBaseServerLink from key vault:",DataBaseServerLink)

secret_name = "DataBasePassword"
DataBasePassword = retrieve_secret(secret_name)
print("Got DataBasePassword from key vault",DataBasePassword)

secret_name = "DataBaseUserName"
DataBaseUserName = retrieve_secret(secret_name)
print("Got DataBaseUserName from key vault",DataBaseUserName)

secret_name = "DataBaseName"
DataBaseName = retrieve_secret(secret_name)
print("Got DataBaseName from key vault",DataBaseName)

secret_name = "OpenWeatherApiKey"
OpenWeatherApiKey = retrieve_secret(secret_name)
print("Got OpenWeatherApiKey from key vault")

secret_name = "GEODBApiKey"
GEODBApiKey = retrieve_secret(secret_name)
print("Got GEODBApiKey from key vault")

app.config['SECRET_KEY'] = str(os.getenv("SECRET_KEY"))

server = str(DataBaseServerLink)
database = str(DataBaseName)
username = str(DataBaseUserName)
password = str(DataBasePassword)
driver = 'ODBC Driver 17 for SQL Server'

# Construct the connection string
params = urllib.parse.quote_plus(
    f'DRIVER={{{driver}}};SERVER={server};DATABASE={database};UID={username};PWD={password}'
)
connection_string = f'mssql+pyodbc:///?odbc_connect={params}'
# Configure the SQLAlchemy part of the app instance
app.config['SQLALCHEMY_DATABASE_URI'] = connection_string
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Create the SQLAlchemy db instance
mysql = SQLAlchemy(app)
bcrypt = Bcrypt(app)

from flask_auth import routes