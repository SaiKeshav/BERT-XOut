#!/bin/bash

cd ~/bert_repo

for config in scripts/configs/*
do
    echo "CONFIG="$config
    BASE=$(basename $config)
    OUTPUT_DIR=$NAME"/"${BASE%.sh}"."$RUN
    bash scripts/run.sh "$@" $OUTPUT_DIR $config
done
