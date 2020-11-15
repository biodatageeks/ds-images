ARG BASE_IMAGE=jupyter/minimal-notebook
FROM $BASE_IMAGE


USER root

ARG JAVA_VERSION=8.0.265.hs-adpt
ARG SCALA_VERSION=2.12.10
ARG SBT_VERSION=1.3.10
ARG SPARK_VERSION
ARG HADOOP_VERSION=2.7
ARG PY4J_VERSION="0.10.9"
ARG NOTEBOOKS_REPO
ARG JUPYTER_KERNEL_NAME
ARG PYTHON_MINOR
ARG SERVICE_ACCOUNT
ARG SPARK_IMAGE


ENV NOTEBOOKS_REPO=$NOTEBOOKS_REPO
ENV JUPYTER_KERNEL_NAME=$JUPYTER_KERNEL_NAME
ENV SERVICE_ACCOUNT=$SERVICE_ACCOUNT

ENV SPARK_VERSION=$SPARK_VERSION
ENV SPARK_IMAGE=$SPARK_IMAGE

RUN apt-get update
RUN apt-get -qq -y install \
    curl \
    unzip \
    zip \
    gcc \
    python-dev \
    python-setuptools \
    libffi-dev \
    jq \
    gettext-base
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ARG USER_NAME=jovyan
ENV HOME=/tmp/$USER_NAME
RUN mkdir -p $HOME && chown -R $USER_NAME $HOME

RUN curl -s https://get.sdkman.io | bash
RUN chmod a+x "$HOME/.sdkman/bin/sdkman-init.sh"
RUN source "$HOME/.sdkman/bin/sdkman-init.sh" && sdk install java ${JAVA_VERSION}
RUN source "$HOME/.sdkman/bin/sdkman-init.sh" && sdk install scala ${SCALA_VERSION}
RUN source "$HOME/.sdkman/bin/sdkman-init.sh" && sdk use java ${JAVA_VERSION}


# Spark installation
WORKDIR /tmp
# Using the preferred mirror to download Spark
# hadolint ignore=SC2046
RUN wget -q https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
RUN tar xzf "spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" -C /usr/local --owner root --group root --no-same-owner && \
    rm "spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"

WORKDIR /usr/local
RUN ln -s "spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}" spark

# Configure Spark
ENV SPARK_HOME=/usr/local/spark
ENV PYTHONPATH="${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-${PY4J_VERSION}-src.zip" \
    SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info" \
    PATH=$PATH:$SPARK_HOME/bin

ADD resources/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ADD resources/.boto_template /tmp/.boto_template

RUN pip install \
    gsutil \
    kubernetes

USER $NB_USER


RUN source /opt/conda/etc/profile.d/conda.sh && \
    conda create python=$PYTHON_MINOR -p $HOME/venv/$JUPYTER_KERNEL_NAME -y && \
    conda activate $HOME/venv/$JUPYTER_KERNEL_NAME && \
    pip install -U ipykernel pandas pyspark==$SPARK_VERSION gsutil && \
    python -m ipykernel install --user --name $JUPYTER_KERNEL_NAME --display-name $JUPYTER_KERNEL_NAME && \
    conda deactivate
RUN cd /tmp && wget https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-hadoop2-latest.jar

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]