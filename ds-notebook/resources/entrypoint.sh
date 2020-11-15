#!/bin/bash -x
export TMP_HOME=/tmp/jovyan
cp -r $TMP_HOME/.sdkman $HOME
source "$HOME/.sdkman/bin/sdkman-init.sh"
echo "$@"

#prepare repos
BIODATAGEEKS_REPOS=${BIODATAGEEKS_REPOS:-"https://oss.sonatype.org/content/repositories/snapshots/"}

#save GCS key
: "${DS_LAB_GCS_KEY:?GCS key is missing!}"

SECRETS_MOUNT_DIR=/tmp/secrets
mkdir -p $SECRETS_MOUNT_DIR && echo $DS_LAB_GCS_KEY > $SECRETS_MOUNT_DIR/$SERVICE_ACCOUNT.json
export GOOGLE_APPLICATION_CREDENTIALS=$SECRETS_MOUNT_DIR/$SERVICE_ACCOUNT.json
export PROJECT_ID=$(cat $GOOGLE_APPLICATION_CREDENTIALS | jq '.project_id' | sed 's/"//g')

envsubst < /tmp/.boto_template > $HOME/.boto

###Packages
if [ $JUPYTER_KERNEL_NAME == "pysequila" ]; then
  SPARK_PACKAGES="--packages org.biodatageeks:sequila_2.11:${SEQUILA_VERSION}"
fi


export PYSPARK_SUBMIT_ARGS="--repositories ${BIODATAGEEKS_REPOS} \
  --jars /tmp/gcs-connector-hadoop2-latest.jar \
  --conf spark.hadoop.google.cloud.auth.service.account.enable=true \
  --conf spark.hadoop.google.cloud.auth.service.account.json.keyfile=$GOOGLE_APPLICATION_CREDENTIALS \
  --conf spark.kubernetes.driverEnv.GCS_PROJECT_ID=$PROJECT_ID \
  --conf spark.kubernetes.driverEnv.GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS \
  --conf spark.executorEnv.GCS_PROJECT_ID=$PROJECT_ID \
  --conf spark.executorEnv.GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS \
  --conf spark.kubernetes.driver.secrets.$SERVICE_ACCOUNT-secret=$SECRETS_MOUNT_DIR \
  --conf spark.kubernetes.executor.secrets.$SERVICE_ACCOUNT-secret=$SECRETS_MOUNT_DIR \
  --conf spark.hadoop.fs.gs.project.id=$PROJECT_ID \
  --conf spark.hadoop.fs.gs.impl=com.google.cloud.hadoop.fs.gcs.GoogleHadoopFileSystem \
  --conf spark.hadoop.fs.AbstractFileSystem.gs.impl=com.google.cloud.hadoop.fs.gcs.GoogleHadoopFS \
  --master k8s://https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT \
  --conf spark.kubernetes.container.image=$SPARK_IMAGE \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=$SERVICE_ACCOUNT \
  --conf spark.kubernetes.authenticate.serviceAccountName=$SERVICE_ACCOUNT \
  --conf spark.driver.port=29010 \
  --conf spark.blockManager.port=29011 \
  --conf spark.kubernetes.namespace=default \
  --conf spark.driver.host=jupyter-service-$JUPYTERHUB_USER \
  --conf spark.driver.bindAddress=$HOSTNAME \
  $SPARK_PACKAGES \
   pyspark-shell"

export PYSPARK_PYTHON=python3

#prepare notebooks
mkdir -p $HOME/work/git
cd $HOME/work/git
git clone $NOTEBOOKS_REPO
cd $HOME



tini -g -- "$@"

