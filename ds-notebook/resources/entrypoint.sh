#!/bin/bash -x
export TMP_HOME=/tmp/jovyan
cp -r $TMP_HOME/.sdkman $HOME
source "$HOME/.sdkman/bin/sdkman-init.sh"
echo "$@"

#prepare repos
BIODATAGEEKS_REPOS=${BIODATAGEEKS_REPOS:-"https://oss.sonatype.org/content/repositories/snapshots/"}

#save GCS key
: "${DS_LAB_GCS_KEY:?GCS key is missing!}"

mkdir -p $HOME/secrets && echo $DS_LAB_GCS_KEY > $HOME/secrets/$SERVICE_ACCOUNT.json
export GOOGLE_APPLICATION_CREDENTIALS=$HOME/secrets/$SERVICE_ACCOUNT.json
export PROJECT_ID=$(cat $GOOGLE_APPLICATION_CREDENTIALS | jq '.project_id' | sed 's/"//g')

envsubst < /tmp/.boto_template > $HOME/.boto

export PYSPARK_SUBMIT_ARGS="--repositories ${BIODATAGEEKS_REPOS}  pyspark-shell"

#prepare notebooks
mkdir -p $HOME/work/git
cd $HOME/work/git
git clone $NOTEBOOKS_REPO
cd $HOME



tini -g -- "$@"

