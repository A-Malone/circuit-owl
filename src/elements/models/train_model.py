import argparse
import os
import shlex
import shutil
import subprocess

#------------------------------------------------------------
#---------------------PARSE ARGUMENTS------------------------
#------------------------------------------------------------

parser = argparse.ArgumentParser(description='Train models')
parser.add_argument('subsystem', help='The subsystem you want to generate ')

args = parser.parse_args()

subsystem_path = os.path.join(os.getcwd(), args.subsystem)
neg_index = os.path.join(subsystem_path, "neg", "index.dat")

samples_dir = os.path.join(subsystem_path, "samples")

#if(not os.path.exists(samples_dir)):
#    raise AssertionError("No samples dir found")

vec_file = os.path.join(samples_dir, "info.vec")

#------------------------------------------------------------
#-------------------LOCATE OUTPUT DIR------------------------
#------------------------------------------------------------
model_dir = os.path.join(subsystem_path, "model")

if (os.path.exists(model_dir)):
    shutil.rmtree(model_dir)

os.makedirs(model_dir)

#------------------------------------------------------------
#------------------------TRAIN MODEL-------------------------
#------------------------------------------------------------
numPos = 50
numNeg = 100

cmd_template = "opencv_traincascade -data {} -vec {} -bg {} -numPos {} -numNeg {} -numStages 20 -nsplits 2 -w 20 -h 20"
cmd_str = cmd_template.format(model_dir, vec_file, neg_index, numPos, numNeg)
print(cmd_str)

subprocess.call(shlex.split(cmd_str))

print("finished")