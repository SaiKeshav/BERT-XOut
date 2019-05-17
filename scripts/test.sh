e!/bin/bash

cd ~/bert_repo

TPU_ID=$1
CKPT_FILE=$2
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

while IFS= read -r line 
do
  POOL=$(echo $line | awk '{print $1}')
  EXP=$(echo $line | awk '{print $2}')
  OUTPUT_DIR=$(echo $line | awk '{print $3}')
  TASK_1=${OUTPUT_DIR#gs://keshav_bert/}
  TASK=${TASK_1%%/*}
  MODEL_1=${OUTPUT_DIR#gs://keshav_bert/$TASK/}
  BERT_MODEL=${MODEL_1%%/*}
  if [ BERT_MODEL = 'large' ]
  then
    BERT_MODEL='uncased_L-24_H-1024_A-16'
  else
    BERT_MODEL='uncased_L-12_H-768_A-12'
  fi
  CKPT=$(basename ${OUTPUT_DIR%_*}| cut -c3-) 
  OUTPUT_DIR=$(dirname $OUTPUT_DIR)

  echo "TASK = "$TASK
  echo "MODEL = "$BERT_MODEL
  echo "CKPT = "$CKPT
  echo "OUTPUT_DIR = "$OUTPUT_DIR
  

  BERT_BASE_DIR="gs://keshav_bert/"$BERT_MODEL
  python run_classifier.py \
  --task_name=$TASK \
  --do_train=false \
  --do_eval=false \
  --do_predict=true \
  --data_dir=$GLUE_DIR/$TASK \
  --vocab_file=$BERT_BASE_DIR/vocab.txt \
  --bert_config_file=$BERT_BASE_DIR/bert_config.json \
  --init_checkpoint=$BERT_BASE_DIR/bert_model.ckpt \
  --max_seq_length=128 \
  --train_batch_size=32 \
  --learning_rate=2e-5 \
  --num_train_epochs=4 \
  --output_dir=$OUTPUT_DIR \
  --use_tpu=True \
  --tpu_name=$TPU_NAME \
  --heads=$HEADS \
  --final_dim=$FINAL_DIM \
  --pool_type=$POOL \
  --exp=$EXP \
  --penalty=False \
  --ckpt=$CKPT
done <"$CKPT_FILE"

