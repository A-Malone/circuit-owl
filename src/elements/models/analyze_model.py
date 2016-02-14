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

samples_dir = os.path.join(subsystem_path, "samples")
dat_file = os.path.join(samples_dir, "info.dat")

model_dir = os.path.join(subsystem_path, "model")
model_file = os.path.join(model_dir, "cascade.xml")

#------------------------------------------------------------
#-----------------------ANALYZE MODEL------------------------
#------------------------------------------------------------

cmd_template = "opencv_performance -data {} -w 20 -h 20 -info {} -ni"
cmd_str = cmd_template.format(model_file, dat_file)

subprocess.call(shlex.split(cmd_str))

print("Complete")