ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG spark_uid=185
ARG MLFLOW_VERSION
USER root
RUN pip3 install mlflow==${MLFLOW_VERSION} \
                 PyArrow==0.15.1
USER ${spark_uid}