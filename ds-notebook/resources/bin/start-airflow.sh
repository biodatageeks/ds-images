#!/usr/bin/env bash
JUPYTERLAB_BASE_URL=${1}
AIRFLOW_PORT=6000

set -x

source /opt/conda/etc/profile.d/conda.sh
conda activate $HOME/venv/$JUPYTER_KERNEL_NAME

if [ ! -d ${AIRFLOW_HOME} ]; then
	echo "Initializing Airflow DB"
	airflow db init
	airflow users create \
    --username admin \
    --firstname Biodatageek \
    --lastname Biodatageek \
    --role Admin \
    --email team@biodatageeks.org \
    --password test1234
	mkdir -p ${AIRFLOW_HOME}/dags
fi


# webserver script
PYTHON_SCRIPT=`cat <<EOF
import sys
from http.server import BaseHTTPRequestHandler,HTTPServer

# html page returned by GET requests
html_disclaimer = """
<!DOCTYPE html>
<html>
	<head>
		<title>Airflow</title>
	</head>
	<body>
		<h1>Info</h1>
		<p>
			Your Airflow is starting up please press the button to continue...
		<p>
		<form method="POST">
			<input type="submit" value="OK" />
		</form>
	</body>
</html>
""".encode('utf-8')

# html page returned by POST requests
html_refresh = """
<!DOCTYPE html>
<html>
	<head>
		<title>Redirect - Airflow</title>
		<meta http-equiv='refresh' content='10'>
	</head>
	<body>
		<h1>Redirecting to Airflow...</h1>
		<p>
			You will be shortly redirected to Airflow. If the redirect doesn't work, please go back to JupyterLab and open Airflow again.
		<p>
	</body>
</html>
""".encode('utf-8')

info_shown=False

class DummyHandler(BaseHTTPRequestHandler):
	def do_GET(self):
		self.send_response(200)
		self.send_header('Content-type','text/html')
		self.end_headers()
		self.wfile.write(html_disclaimer)
		return
	def do_POST(self):
		self.send_response(200)
		self.send_header('Content-type','text/html')
		self.end_headers()
		self.wfile.write(html_refresh)
		global info_shown
		info_shown=True
		return

server = HTTPServer(('', ${AIRFLOW_PORT}), DummyHandler)

while not info_shown:
	server.handle_request()
EOF`

python -c "$PYTHON_SCRIPT"


# set the base url for airflow webserver
export AIRFLOW__WEBSERVER__BASE_URL="https://${LAB_DOMAIN}/user/${USER}/airflow"
export AIRFLOW__WEBSERVER__ENABLE_PROXY_FIX="True"
#load examples
export AIRFLOW__CORE__LOAD_EXAMPLES="True"

airflow webserver --port $AIRFLOW_PORT &
airflow scheduler &

wait

conda deactivate