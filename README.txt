python3 -m venv antenv
source antenv/bin/activate
apt-get install pkg-config -y --ignore-missing
apt-get install dos2unix
apt-get install default-libmysqlclient-dev -y --ignore-missing
FILEPATH=$(find . -type f -name odbc17.sh)
dos2unix "$FILEPATH"
bash $FILEPATH
python3 app.py


https://medium.com/@adnanrahic/hello-world-app-with-node-js-and-express-c1eb7cfa8a30

apt-get install python3 -y
apt-get install python3-pip -y
apt-get install zip -y

apt-get install dos2unix -y




apt-get install python3-venv -y
python3 -m venv venv
source venv/bin/activate
apt-get install pkg-config -y --ignore-missing
apt-get install libmysqlclient-dev -y --ignore-missing

FILEPATH=$(find /home/ -type f -name odbc17.sh)
if [ -f "$FILEPATH" ]; then
	echo "Found odbc17.sh at $FILEPATH"
    echo 'Password@12345' | sudo -S dos2unix "$FILEPATH"
    echo 'Password@12345' | sudo -S bash -c "bash $FILEPATH"
else
    echo "odbc17.sh not found"
fi