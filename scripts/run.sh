#!/bin/bash

cd ~/bert_repo

TPU_ID=$1
BERT_MODEL=$2
TASK=$3
EPOCH=$4
OUTPUT_DIR=$5
CONFIG=$6
if [ $TPU_ID = "1" ]
then
  TPU_NAME='grpc://10.0.101.2:8470'
elif [ $TPU_ID = "2" ]
then
  TPU_NAME='grpc://10.240.1.2:8470'
elif [ $TPU_ID = "3" ]
then
  TPU_NAME='grpc://10.23.42.202:8470'
elif [ $TPU_ID = "4" ]
then
  TPU_NAME='grpc://192.168.0.2:8470'
elif [ $TPU_ID = "5" ]
then
  TPU_NAME='grpc://10.192.10.194:8470'
fi

echo "Using TPU: "$TPU_NAME

BUCKET='keshav_bert' 
OUTPUT_DIR='gs://'$BUCKET'/'$TASK'/'$BERT_MODEL'/'$OUTPUT_DIR
if [ BERT_MODEL = 'large' ]
then
  BERT_MODEL='uncased_L-24_H-1024_A-16'
else
  BERT_MODEL='uncased_L-12_H-768_A-12'
fi

BERT_BASE_DIR="gs://keshav_bert/"$BERT_MODEL
GLUE_DIR='glue_data/'
if [ -z "$HEADS" ]
then
	HEADS=0
  FINAL_DIM=100
fi 

echo "Pool type = "$POOL
echo "Exp type = "$EXP
echo "Using "$HEADS" heads"
echo $OUTPUT_DIR 

source $CONFIG
echo "LR="$LR
echo "BS="$BS

python run_classifier.py \
  --task_name=$TASK \
  --do_train=true \
  --do_eval=false \
  --do_predict=false \
  --data_dir=$GLUE_DIR/$TASK \
  --vocab_file=$BERT_BASE_DIR/vocab.txt \
  --bert_config_file=$BERT_BASE_DIR/bert_config.json \
  --init_checkpoint=$BERT_BASE_DIR/bert_model.ckpt \
  --max_seq_length=128 \
  --train_batch_size=$BS \
  --learning_rate=$LR \
  --num_train_epochs=$EPOCH \
  --output_dir=$OUTPUT_DIR \
  --use_tpu=True \
  --tpu_name=$TPU_NAME \
  --heads=$HEADS \
  --final_dim=$FINAL_DIM \
  --pool_type=$POOL \
  --exp=$EXP \
  --penalty=False

#FILES=$(gsutil ls $OUTPUT_DIR"*.index")
FILES=$(gsutil ls -l $OUTPUT_DIR"/*.index" | sort -k 2 | awk '{print $NF}' | head -n -1 | tail -n +3)
echo $FILES
for FILE in $FILES;
do 
  ckpt=$(basename ${FILE%.*})
  python run_classifier.py \
  --task_name=$TASK \
  --do_train_and_eval=false \
  --do_train=false \
  --do_eval=true \
  --do_predict=false \
  --data_dir=$GLUE_DIR/$TASK \
  --vocab_file=$BERT_BASE_DIR/vocab.txt \
  --bert_config_file=$BERT_BASE_DIR/bert_config.json \
  --init_checkpoint=$BERT_BASE_DIR/bert_model.ckpt \
  --max_seq_length=128 \
  --train_batch_size=32 \
  --learning_rate=2e-5 \
  --num_train_epochs=$EPOCH \
  --output_dir=$OUTPUT_DIR \
  --use_tpu=True \
  --tpu_name=$TPU_NAME \
  --heads=$HEADS \
  --final_dim=$FINAL_DIM \
  --pool_type=$POOL \
  --exp=$EXP \
  --penalty=False \
  --ckpt=$ckpt
done
 

