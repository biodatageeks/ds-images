#!/usr/bin/env bash

export VERSION=3.6.3-4
#general
export PROJECT_NAME=studiapodyplomowe
export GIT_SUBMODULE_STRATEGY=recursive
export VERSION_FILE=version.sh
export GIT_DEPTH=500
export DOCKER_VERSION=19.03.12
export JDK_VERSION=11.0.11.hs-adpt
export SBT_VERSION=1.3.10
export BASE_IMAGE=jupyter/minimal-notebook:lab-3.6.3
export IMAGE_NAME=ds-notebook
export NAMESPACE_IMAGE_NAME=biodatageeks/${IMAGE_NAME}
export SERVICE_ACCOUNT="ds-lab-sa"

export SPARK_IMAGE_NAME="spark-py"
export GSUTIL_VERSION="5.23"
export MLFLOW_VERSION=2.3.1
export MLFLOW_ENABLED="false"
export AUTO_BUCKET_ENABLED="false"
export AIRFLOW_ENABLED="false"
export AIRFLOW_VERSION=2.0.0
export BIG_DATA_GENOMICS_ENABLED="false"
export GLOW_VERSION="io.projectglow:glow-spark2_2.12:1.1.1"
export GLOW_PY_VERSION=0.6.0
export SEQUILA_VERSION="org.biodatageeks:sequila_2.12:0.7.0"
export PYSEQUILA_VERSION=0.1.8
export SEQTENDER_VERSION="org.biodatageeks:seqtender_2.11:0.3.7"
export PYSEQTENDER_VERSION=0.1.1
export LAB_DOMAIN=lab.biodatageeks.org
export GCR_SA=container-admin@studiapodyplomowe.iam.gserviceaccount.com
export GCR_SA_KEY="/root/gcr/sa.json"
export CLOUD_SDK_VERSION=321.0.0
export KUBECTL_VERSION=1.27.1
export GCS_NIO_VERSION=0.120.0-alpha
export GCS_CONNECTOR_VERSION=hadoop2-1.9.17
export VEP_VERSION="101.0"
export SPARK_PVC_NAME=pvc-shared-pipeline
export SEQUILA_DEV_ENABLED="false"
export KEDRO_ENABLED="false"
export KEDRO_VERSION=0.18.1
export VS_CODE_ENABLED="false"
export VS_CODE_VERSION=3.10.2


export SPARK_VERSION="3.2.4"
export SPARK_IMAGE=biodatageeks/spark-py:v3.2.4-ds
export PYTHON_MINOR="3.9"
export SCALA_VERSION=2.12.13
export JUPYTER_KERNEL_NAME=datascience
export MLFLOW_ENABLED="true"
export AUTO_BUCKET_ENABLED="true"
export AIRFLOW_ENABLED="false"
export BIG_DATA_GENOMICS_ENABLED="false"
export VS_CODE_ENABLED="true"
export KEDRO_ENABLED="true"
export NOTEBOOKS_REPO=https://github.com/biodatageeks/ds-notebooks

docker build \
      --build-arg BASE_IMAGE=$BASE_IMAGE \
      --build-arg JAVA_VERSION=$JDK_VERSION \
      --build-arg SCALA_VERSION=$SCALA_VERSION \
      --build-arg SBT_VERSION=$SBT_VERSION \
      --build-arg SPARK_VERSION=$SPARK_VERSION \
      --build-arg NOTEBOOKS_REPO=$NOTEBOOKS_REPO \
      --build-arg JUPYTER_KERNEL_NAME=$JUPYTER_KERNEL_NAME \
      --build-arg PYTHON_MINOR=$PYTHON_MINOR \
      --build-arg SERVICE_ACCOUNT=$SERVICE_ACCOUNT \
      --build-arg SPARK_IMAGE=$SPARK_IMAGE \
      --build-arg GSUTIL_VERSION=$GSUTIL_VERSION \
      --build-arg MLFLOW_VERSION=$MLFLOW_VERSION \
      --build-arg MLFLOW_ENABLED=$MLFLOW_ENABLED \
      --build-arg AUTO_BUCKET_ENABLED=$AUTO_BUCKET_ENABLED \
      --build-arg AIRFLOW_VERSION=$AIRFLOW_VERSION \
      --build-arg AIRFLOW_ENABLED=$AIRFLOW_ENABLED \
      --build-arg BIG_DATA_GENOMICS_ENABLED=$BIG_DATA_GENOMICS_ENABLED \
      --build-arg GLOW_PY_VERSION=$GLOW_PY_VERSION \
      --build-arg GLOW_VERSION=$GLOW_VERSION \
      --build-arg SEQUILA_VERSION=$SEQUILA_VERSION \
      --build-arg PYSEQUILA_VERSION=$PYSEQUILA_VERSION \
      --build-arg SEQTENDER_VERSION=$SEQTENDER_VERSION \
      --build-arg PYSEQTENDER_VERSION=$PYSEQTENDER_VERSION \
      --build-arg LAB_DOMAIN=$LAB_DOMAIN \
      --build-arg KUBECTL_VERSION=$KUBECTL_VERSION \
      --build-arg GCS_NIO_VERSION=$GCS_NIO_VERSION \
      --build-arg GCS_CONNECTOR_VERSION=$GCS_CONNECTOR_VERSION \
      --build-arg VEP_VERSION=$VEP_VERSION \
      --build-arg SPARK_PVC_NAME=$SPARK_PVC_NAME \
      --build-arg SEQUILA_DEV_ENABLED=$SEQUILA_DEV_ENABLED \
      --build-arg KEDRO_ENABLED=$KEDRO_ENABLED \
      --build-arg KEDRO_VERSION=$KEDRO_VERSION \
      --build-arg VS_CODE_VERSION=$VS_CODE_VERSION \
      --build-arg VS_CODE_ENABLED=$VS_CODE_ENABLED \
      -t $NAMESPACE_IMAGE_NAME:spark-$JUPYTER_KERNEL_NAME-$SPARK_VERSION-$VERSION .

docker push $NAMESPACE_IMAGE_NAME:spark-$JUPYTER_KERNEL_NAME-$SPARK_VERSION-$VERSION