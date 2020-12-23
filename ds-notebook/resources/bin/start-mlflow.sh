#!/usr/bin/env bash

MLFLOW_UI_PORT=${1}

set -x

MFLOW_HOME=$HOME/mlflow

mkdir -p $MFLOW_HOME/experiments

source /opt/conda/etc/profile.d/conda.sh
conda activate $HOME/venv/$JUPYTER_KERNEL_NAME

mlflow server --host 0.0.0.0 --port $MLFLOW_UI_PORT \
--default-artifact-root gs://bdg-lab-${USER}/mlflow/artifacts \
--backend-store-uri sqlite:///${MFLOW_HOME}/experiments/mlflow.db &

conda deactivate