#!/bin/bash

TMP_DIR=".tmp_exercises"
PATCH_DIR=".patches"

mkdir -p $TMP_DIR

cp -R "./exercises/" $TMP_DIR

for section in `ls $PATCH_DIR`
    do
        for exo in `ls $PATCH_DIR/$section`
        do
            patch $TMP_DIR/$section/"${exo%.*}" < "$PATCH_DIR/$section/$exo"
            mv $TMP_DIR/$section/"${exo%.*}" $TMP_DIR/$section/"test_${exo%.*}"
        done
    done
    
protostar test $TMP_DIR

rm -rf $TMP_DIR