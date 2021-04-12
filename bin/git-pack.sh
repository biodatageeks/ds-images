#!/usr/bin/env bash

[ $# -eq 0 ] && { echo "Usage: $0 [branch/tag] [tar.gz|zip]"; exit 1; }

PROJECT_NAME=$(  pwd | rev | cut -f1 -d'/' | rev )
VERSION=${1:-"master"}
FORMAT=${2:-"tar.gz"}
DEST_DIR=target
mkdir -p $DEST_DIR
echo "Preparing a package from branch/tag: $VERSION using $FORMAT ..."
git archive --format=$FORMAT --prefix=$PROJECT_NAME-$VERSION/ $VERSION > $DEST_DIR/$PROJECT_NAME-$VERSION.$FORMAT
echo "Listing archive contents..."
tar --gzip --list --verbose --file=$DEST_DIR/$PROJECT_NAME-$VERSION.$FORMAT