#!/bin/bash -x
export TMP_HOME=/tmp/jovyan
cp -r $TMP_HOME/.sdkman $HOME
source "$HOME/.sdkman/bin/sdkman-init.sh"
echo "$@"

#prepare repos
BIODATAGEEKS_REPOS=${BIODATAGEEKS_REPOS:-"https://oss.sonatype.org/content/repositories/snapshots/"}

#PYSEQUILA
PYSEQUILA_VERSION=${PYSEQUILA_VERSION:-"0.2.0"}
#save GCS key
: "${DS_LAB_GCS_KEY:?GCS key is missing!}"

export SECRETS_MOUNT_DIR=/tmp/secrets
mkdir -p $SECRETS_MOUNT_DIR && echo $DS_LAB_GCS_KEY > $SECRETS_MOUNT_DIR/$SERVICE_ACCOUNT.json
export GOOGLE_APPLICATION_CREDENTIALS=$SECRETS_MOUNT_DIR/$SERVICE_ACCOUNT.json
export PROJECT_ID=$(cat $GOOGLE_APPLICATION_CREDENTIALS | jq '.project_id' | sed 's/"//g')

envsubst < /tmp/.boto_template > $HOME/.boto

###Packages
if [ $BIG_DATA_GENOMICS_ENABLED == "true" ]; then
  SPARK_PACKAGES="--packages ${SEQUILA_VERSION},${GLOW_VERSION},${SEQTENDER_VERSION}"
fi

if [ $MLFLOW_ENABLED == "true" ]; then
  export MLFLOW_TRACKING_URI=http://localhost:5000
fi

if [ $SEQUILA_DEV_ENABLED == "true" ]; then
    source /opt/conda/etc/profile.d/conda.sh
    conda activate $TMP_HOME/venv/$JUPYTER_KERNEL_NAME
    pip install -U pysequila==$PYSEQUILA_VERSION
    conda deactivate
fi

export PYSPARK_PYTHON=python3

export PYSPARK_SUBMIT_ARGS="--repositories ${BIODATAGEEKS_REPOS} \
  --jars /tmp/gcs-connector-${GCS_CONNECTOR_VERSION}-shaded.jar,/tmp/google-cloud-nio-${GCS_NIO_VERSION}-shaded.jar,$HAIL_HOME/hail-all-spark.jar \
  --conf spark.hadoop.google.cloud.auth.service.account.enable=true \
  --conf spark.hadoop.google.cloud.auth.service.account.json.keyfile=$GOOGLE_APPLICATION_CREDENTIALS \
  --conf spark.kubernetes.driverEnv.GCS_PROJECT_ID=$PROJECT_ID \
  --conf spark.kubernetes.driverEnv.GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS \
  --conf spark.executorEnv.GCS_PROJECT_ID=$PROJECT_ID \
  --conf spark.executorEnv.GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS \
  --conf spark.kubernetes.driver.secrets.$SERVICE_ACCOUNT-secret=$SECRETS_MOUNT_DIR \
  --conf spark.kubernetes.driver.extraClassPath=$HAIL_HOME/hail-all-spark.jar \
  --conf spark.kubernetes.executor.extraClassPath=./hail-all-spark.jar \
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
  --conf spark.kryo.registrator=is.hail.kryo.HailKryoRegistrator \
  --conf spark.kubernetes.executor.secrets.$SERVICE_ACCOUNT-secret=$SECRETS_MOUNT_DIR \
  --conf spark.hadoop.fs.gs.project.id=$PROJECT_ID \
  --conf spark.hadoop.fs.gs.impl=com.google.cloud.hadoop.fs.gcs.GoogleHadoopFileSystem \
  --conf spark.hadoop.fs.AbstractFileSystem.gs.impl=com.google.cloud.hadoop.fs.gcs.GoogleHadoopFS \
  --master k8s://https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT \
  --conf spark.kubernetes.container.image=$SPARK_IMAGE \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=$SERVICE_ACCOUNT \
  --conf spark.kubernetes.authenticate.serviceAccountName=$SERVICE_ACCOUNT \
  --conf spark.kubernetes.executor.podNamePrefix=pyspark-exec-$JUPYTERHUB_USER \
  --conf spark.kubernetes.executor.label.spark-owner=$JUPYTERHUB_USER \
  --conf spark.kubernetes.executor.request.cores=0.4 \
  --conf spark.kubernetes.executor.volumes.persistentVolumeClaim.${SPARK_PVC_NAME}.options.claimName=${SPARK_PVC_NAME} \
  --conf spark.kubernetes.executor.volumes.persistentVolumeClaim.${SPARK_PVC_NAME}.mount.path=/mnt/data \
  --conf spark.kubernetes.executor.volumes.persistentVolumeClaim.${SPARK_PVC_NAME}.mount.readOnly=true \
  --conf spark.kubernetes.executor.podTemplateFile=/tmp/exec_pod_template.template
  --conf spark.driver.port=29010 \
  --conf spark.blockManager.port=29011 \
  --conf spark.kubernetes.namespace=default \
  --conf spark.driver.host=jupyter-service-$JUPYTERHUB_USER \
  --conf spark.driver.bindAddress=$HOSTNAME \
  --conf spark.executorEnv.PYSPARK_PYTHON=$PYSPARK_PYTHON \
  $SPARK_PACKAGES \
   pyspark-shell"



#prepare notebooks
mkdir -p $HOME/work/git
cd $HOME/work/git
git clone $NOTEBOOKS_REPO
for dir in $( ls -1 ); do
  cd $dir && git pull --rebase
  cd ..
done
cd $HOME

if [ $AUTO_BUCKET_ENABLED == "true" ]; then
  if [ $(gsutil ls | grep -e gs://bdg-lab-$USER/$ | wc -l) -eq 0 ]; then
    echo "Creating bucket: gs://bdg-lab-$USER"
    gsutil mb gs://bdg-lab-$USER
  fi
fi

tini -g -- "$@"

