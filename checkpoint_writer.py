import tensorflow as tf
import sys

DIR=sys.argv[1]
ckpt=sys.argv[2]

with tf.gfile.GFile(DIR+'/checkpoint', "w") as writer:
    s = "model_checkpoint_path: \"{}\"\n"%ckpt
    writer.write(s)
