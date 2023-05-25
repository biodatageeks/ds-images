#!/usr/bin/env bash
export JUPYTER_KERNEL_NAME=datascience
export MLFLOW_VERSION=2.3.1
docker build --build-arg BASE_IMAGE=apache/spark-py:v3.2.4 \
             --build-arg JUPYTER_KERNEL_NAME=$JUPYTER_KERNEL_NAME \
             --build-arg MLFLOW_VERSION=$MLFLOW_VERSION \
             -t biodatageeks/spark-py:v3.2.4-ds . && \
docker push biodatageeks/spark-py:v3.2.4-ds
