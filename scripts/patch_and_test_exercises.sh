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
    
$HOME/.protostar/dist/protostar/protostar test $TMP_DIR

rm -rf $TMP_DIR
