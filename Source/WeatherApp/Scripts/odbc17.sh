#!/bin/bash

echo "Starting odbc17.sh script..."

# Check if the Ubuntu version is supported
if ! [[ "16.04 18.04 20.04 22.04" == *"$(lsb_release -rs)"* ]]; then
    echo "Ubuntu $(lsb_release -rs) is not currently supported."
    exit 1
fi

# Add Microsoft package repositories
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc

curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list

# Update package lists and install ODBC drivers and tools
apt-get update #sudo
ACCEPT_EULA=Y apt-get install -y msodbcsql17 #sudo

# Optional: for bcp and sqlcmd
ACCEPT_EULA=Y apt-get install -y mssql-tools #sudo
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc

# Optional: for unixODBC development headers
apt-get install -y unixodbc-dev #sudo

echo "Finished odbc17.sh script."
