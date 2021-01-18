#!/usr/bin/env bash
echo "####Running GATK with users' params: $@ on Kubernetes"
gatk HaplotypeCallerSpark \
  --spark-runner SPARK \
  --spark-master k8s://https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT \
  --conf spark.jars=/tmp/gcs-connector-${GCS_CONNECTOR_VERSION}-shaded.jar,/tmp/google-cloud-nio-${GCS_NIO_VERSION}-shaded.jar \
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
  --conf spark.kubernetes.container.image=gcr.io/studiapodyplomowe/biodatageeks/spark-py:v2.4.3-edugen-0.1.7-gatk \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=$SERVICE_ACCOUNT \
  --conf spark.kubernetes.authenticate.serviceAccountName=$SERVICE_ACCOUNT \
  --conf spark.kubernetes.executor.podNamePrefix=gatk-exec-$USER \
  --conf spark.kubernetes.executor.label.spark-owner=$USER \
  --conf spark.kubernetes.executor.request.cores=0.4 \
  --conf spark.driver.port=29010 \
  --conf spark.blockManager.port=29011 \
  --conf spark.kubernetes.namespace=default \
  --conf spark.driver.host=jupyter-service-$USER \
  --conf spark.driver.bindAddress=$HOSTNAME \
  --conf spark.executorEnv.PYSPARK_PYTHON=$PYSPARK_PYTHON \
  "$@"