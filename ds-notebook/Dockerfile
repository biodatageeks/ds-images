ARG BASE_IMAGE=jupyter/minimal-notebook
FROM $BASE_IMAGE


USER root

ARG JAVA_VERSION=8.0.292.hs-adpt
ARG SCALA_VERSION=2.12.10
ARG SBT_VERSION=1.3.10
ARG SPARK_VERSION
ARG HADOOP_VERSION=2.7
ARG PIP_VERSION=23.1.2
ARG PY4J_VERSION="0.10.9"
ARG NOTEBOOKS_REPO
ARG JUPYTER_KERNEL_NAME
ARG PYTHON_MINOR
ARG SERVICE_ACCOUNT
ARG SPARK_IMAGE
ARG GSUTIL_VERSION
ARG IGV_JUPYTER_VERSION=2.0.4
ARG GATK_VERSION=4.1.9.0
ARG MLFLOW_VERSION
ARG MLFLOW_ENABLED
ARG AUTO_BUCKET_ENABLED
ARG AIRFLOW_ENABLED
ARG AIRFLOW_VERSION
ARG BIG_DATA_GENOMICS_ENABLED
ARG GLOW_PY_VERSION
ARG GLOW_VERSION
ARG SEQUILA_VERSION
ARG PYSEQUILA_VERSION
ARG SEQTENDER_VERSION
ARG PYSEQTENDER_VERSION
ARG LAB_DOMAIN
ARG GCS_NIO_VERSION
ARG KUBECTL_VERSION
ARG GCS_CONNECTOR_VERSION
ARG VEP_VERSION
ARG SPARK_PVC_NAME
ARG SEQUILA_DEV_ENABLED
ARG VS_CODE_ENABLED
ARG KEDRO_ENABLED
ARG KEDRO_VERSION

ENV MLFLOW_ENABLED=$MLFLOW_ENABLED
ENV AUTO_BUCKET_ENABLED=$AUTO_BUCKET_ENABLED
ENV AIRFLOW_ENABLED=$AIRFLOW_ENABLED
ENV BIG_DATA_GENOMICS_ENABLED=$BIG_DATA_GENOMICS_ENABLED
ENV SEQUILA_DEV_ENABLED=$SEQUILA_DEV_ENABLED
ENV GLOW_VERSION=$GLOW_VERSION
ENV SEQUILA_VERSION=$SEQUILA_VERSION
ENV SEQTENDER_VERSION=$SEQTENDER_VERSION
ENV VS_CODE_ENABLED=$VS_CODE_ENABLED
ENV KEDRO_ENABLED=$KEDRO_ENABLED


ENV NOTEBOOKS_REPO=$NOTEBOOKS_REPO
ENV JUPYTER_KERNEL_NAME=$JUPYTER_KERNEL_NAME
ENV SERVICE_ACCOUNT=$SERVICE_ACCOUNT

ENV SPARK_VERSION=$SPARK_VERSION
ENV SPARK_IMAGE=$SPARK_IMAGE
ENV LAB_DOMAIN=$LAB_DOMAIN
ENV GCS_NIO_VERSION=$GCS_NIO_VERSION
ENV GCS_CONNECTOR_VERSION=$GCS_CONNECTOR_VERSION

ARG VS_CODE_VERSION
ENV VS_CODE_VERSION=$VS_CODE_VERSION


RUN apt-get update --fix-missing && apt-get -qq -y install \
    curl \
    unzip \
    zip \
    gcc \
    python${PYTHON_MINOR} \
    python-setuptools \
    libffi-dev \
    jq \
    gettext-base \
    build-essential \
    libz-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-gnutls-dev \
    libssl-dev \
    g++ \
    vcftools
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
    gsutil==$GSUTIL_VERSION \
    kubernetes==26.1.0 \
    pylint==2.8.3 \
    jupyter-server-proxy==4.0.0 && \
    jupyter labextension install @jupyterlab/server-proxy

RUN cd /tmp && \
    git clone https://github.com/yuvipanda/jupyter-launcher-shortcuts.git && \
    cd jupyter-launcher-shortcuts && \
    git checkout 39af7a2d201ceaa27dc6cbc8ab5b93a26a763697 && \
    pip install -e . && \
    jupyter labextension install jupyterlab-launcher-shortcuts@3.0.0 && \
    jupyter serverextension enable jupyter_launcher_shortcuts --sys-prefix



ENV PATH=$PATH:/opt/gatk-$GATK_VERSION:/opt/vt:/opt/ensembl-vep

RUN mkdir -p /opt/tools/{bin,logos} && chmod -R 755 /opt/tools/
ADD resources/bin/*.sh /opt/tools/bin/
ADD resources/logos/* /opt/tools/logos/

ADD resources/config/jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

RUN cd /tmp && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

RUN mkdir -p /mnt/data && chown -R $NB_USER /mnt/data
ADD resources/edugen/bin/* /usr/local/bin/
RUN apt-get update --fix-missing && apt-get install python3-opencv -y

RUN apt-get update --fix-missing && apt-get -qq -y install lsb-release gnupg && \
    export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s` && \
    echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
    apt-get update && apt-get -qq -y install gcsfuse

RUN pip install -U nbresuse==0.4.0 && \
    jupyter labextension install jupyterlab-topbar-extension jupyterlab-system-monitor

RUN if [ $JUPYTER_KERNEL_NAME == "edugen" ]; then \
   apt install -y unzip \
      curl \
      libmodule-build-perl \
      libdbi-perl \
      libdbd-mysql-perl \
      build-essential \
      cpanminus \
      zlib1g-dev && \
    cd /tmp && \
    git clone https://github.com/Ensembl/ensembl-vep.git && \
    cd ensembl-vep && \
    cpanm inc::latest && \
    cpanm Module::Build && \
    git checkout release/$VEP_VERSION && \
    perl INSTALL.pl -n -a a && \
    mkdir -p /opt && cp -r /tmp/ensembl-vep /opt/ && \
    cd /tmp && \
    git clone https://github.com/atks/vt.git  && \
    cd vt && \
    git checkout 0.57721 && \
    make && \
    mv vt /usr/bin; \
    fi

RUN cd /opt/ && wget https://github.com/cdr/code-server/releases/download/v${VS_CODE_VERSION}/code-server_${VS_CODE_VERSION}_amd64.deb && \
    wget https://github.com/cdr/code-server/releases/download/v${VS_CODE_VERSION}/code-server-${VS_CODE_VERSION}-linux-amd64.tar.gz && \
    tar zxvf code-server-${VS_CODE_VERSION}-linux-amd64.tar.gz

USER $NB_USER
RUN /opt/code-server-*-linux-amd64/bin/code-server \
    --extensions-dir /tmp/$NB_USER/extensions \
    --user-data-dir /tmp/$NB_USER/data \
    --config /tmp/$NB_USER/config.yaml \
    --install-extension ms-python.python

RUN source /opt/conda/etc/profile.d/conda.sh && \
    conda create python=$PYTHON_MINOR -p $HOME/venv/$JUPYTER_KERNEL_NAME -y && \
    conda activate $HOME/venv/$JUPYTER_KERNEL_NAME && \
    pip install -U ipykernel==6.22.0 \
                    pandas==1.5.3 \
                    pyspark==$SPARK_VERSION \
                    googledrivedownloader==0.4 \
                    matplotlib==3.7.1 \
                    seaborn==0.12.2 \
                    gsutil==$GSUTIL_VERSION \
                    ipython_genutils==0.2.0 \
                    google-cloud-storage==2.9.0 && \
    python -m ipykernel install --user --name $JUPYTER_KERNEL_NAME --display-name $JUPYTER_KERNEL_NAME && \
    conda deactivate

RUN  source /opt/conda/etc/profile.d/conda.sh && \
     conda activate $HOME/venv/$JUPYTER_KERNEL_NAME && \
     if [ $JUPYTER_KERNEL_NAME == "edugen" ]; then \
        pip install -U pip==$PIP_VERSION && \
        pip install -U pysam \
                       multiqc \
                       biothings_client; \
#                       igv-jupyterlab==$IGV_JUPYTER_VERSION; \ FIXME: no longer supported in jupyterlab < 3.x
    fi && \
    if [ $MLFLOW_ENABLED == "true" ]; then \
        pip install -U pip==$PIP_VERSION && \
        pip install -U mlflow==$MLFLOW_VERSION; \
    fi && \
    if [ $AIRFLOW_ENABLED == "true" ]; then \
        pip install -U pip==$PIP_VERSION && \
        pip install -U apache-airflow==$AIRFLOW_VERSION \
                       apache-airflow-providers-cncf-kubernetes; \
    fi && \
    if [ $BIG_DATA_GENOMICS_ENABLED == "true" ]; then \
        pip install -U pip==$PIP_VERSION && \
        pip install -U pysequila==$PYSEQUILA_VERSION \
                       opencv-python==4.5.1.48 \
#                       pyseqtender==$PYSEQTENDER_VERSION \ /FIXME:temporary disabling pyseqtender does not support spark 3.0.1
                       glow.py==$GLOW_PY_VERSION; \
    fi && \
    if [ $KEDRO_ENABLED == "true" ]; then \
        pip install -U pip==$PIP_VERSION && \
        pip install -U kedro==$KEDRO_VERSION \
                       kedro-viz kedro-mlflow==0.11.8; \
    fi && \
    conda deactivate

RUN cd /tmp && wget https://repo1.maven.org/maven2/com/google/cloud/bigdataoss/gcs-connector/${GCS_CONNECTOR_VERSION}/gcs-connector-${GCS_CONNECTOR_VERSION}-shaded.jar && \
    wget https://repo1.maven.org/maven2/com/google/cloud/google-cloud-nio/${GCS_NIO_VERSION}/google-cloud-nio-${GCS_NIO_VERSION}-shaded.jar


#airflow
ENV AIRFLOW_HOME=/home/$USER_NAME/airflow
ENV VEP_VERSION=$VEP_VERSION
ENV SPARK_PVC_NAME=$SPARK_PVC_NAME

#spark pod template
ADD resources/spark/exec_pod_template.template /tmp/


#install k9s
RUN curl -sS https://webinstall.dev/k9s | bash
ENV PATH=$PATH:/tmp/jovyan/.local/bin

#kedro
ENV KEDRO_VERSION=$KEDRO_VERSION
ENV PYTHON_MINOR=$PYTHON_MINOR
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]