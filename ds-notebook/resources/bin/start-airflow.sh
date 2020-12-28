#!/usr/bin/env bash
JUPYTERLAB_BASE_URL=${1}
AIRFLOW_PORT=${2}

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


# set the base url for airflow webserver
export AIRFLOW__WEBSERVER__BASE_URL="https://${LAB_DOMAIN}/user/${USER}/airflow"
#load examples
export AIRFLOW__CORE__LOAD_EXAMPLES="True"

airflow webserver --port 6000 &
airflow scheduler &

wait

conda deactivate