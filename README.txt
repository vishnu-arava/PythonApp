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