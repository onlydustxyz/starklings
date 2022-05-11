#!/bin/bash

ROOT_DIR=$(pwd)
TMP_DIR="/tmp/tmp_exercises"
PATCH_DIR="$ROOT_DIR/.patches"

mkdir -p $TMP_DIR

cp -r "$ROOT_DIR/exercises/." "$TMP_DIR/"

for section in `ls $PATCH_DIR`
    do
        for exo in `ls $PATCH_DIR/$section`
        do
            patch $TMP_DIR/$section/"${exo%.*}" < "$PATCH_DIR/$section/$exo"
            mv $TMP_DIR/$section/"${exo%.*}" $TMP_DIR/$section/"test_${exo%.*}"
        done
    done
    
RESULT=$($HOME/.protostar/dist/protostar/protostar test $TMP_DIR 2>&1 | grep -iF "failed")

rm -rf $TMP_DIR

if [ -z "$RESULT" ]
then
    echo "All exercises passed"
    exit 0
else
    echo "Some exercises failed"
    exit 1
fi
