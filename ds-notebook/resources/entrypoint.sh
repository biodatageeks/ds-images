#!/bin/bash -x
export TMP_HOME=/tmp/jovyan
cp -r $TMP_HOME/.sdkman $HOME
source "$HOME/.sdkman/bin/sdkman-init.sh"
echo "$@"

#prepare repos
BIODATAGEEKS_REPOS=${BIODATAGEEKS_REPOS:-"https://oss.sonatype.org/content/repositories/snapshots/"}


export PYSPARK_SUBMIT_ARGS="--repositories ${BIODATAGEEKS_REPOS}  pyspark-shell"

#prepare notebooks
mkdir -p $HOME/work/git
cd $HOME/work/git
git clone $NOTEBOOKS_REPO
cd $HOME

tini -g -- "$@"

