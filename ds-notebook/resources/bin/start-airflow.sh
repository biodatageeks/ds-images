#!/usr/bin/env bash

AIRFLOW_PORT=${1}

set -x

source /opt/conda/etc/profile.d/conda.sh
conda activate $HOME/venv/$JUPYTER_KERNEL_NAME

if [ ! -d ${AIRFLOW_HOME} ]; then
	echo "Initializing Airflow DB"
	airflow initdb
	airflow users create \
    --username admin \
    --firstname Biodatageek \
    --lastname Biodatageek \
    --role Admin \
    --email team@biodatageeks.org
	mkdir -p ${AIRFLOW_HOME}/dags
fi



airflow webserver --port ${AIRFLOW_PORT} &
airflow scheduler -D

conda deactivate