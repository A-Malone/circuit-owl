import argparse
import os
import shlex
import shutil
import subprocess

#------------------------------------------------------------
#---------------------PARSE ARGUMENTS------------------------
#------------------------------------------------------------

parser = argparse.ArgumentParser(description='Create samples or subsystems')
parser.add_argument('subsystem', help='The subsystem you want to generate ')
parser.add_argument('--num', dest='num', type=int, default=1000)

args = parser.parse_args()

subsystem_path = os.path.join(os.getcwd(), args.subsystem)

pos_index = os.path.join(subsystem_path, "pos", "index.dat")
neg_index = os.path.join(subsystem_path, "neg", "index.dat")

pos_images =[]
neg_images = [] 

with open(pos_index, 'r') as f:
    pos_images = f.readlines()

num_created = 0
samples_per = int(args.num / len(pos_images))

#------------------------------------------------------------
#-------------------CREATE OUTPUT DIR------------------------
#------------------------------------------------------------
samples_dir = os.path.join(subsystem_path, "samples")

if (os.path.exists(samples_dir)):
    shutil.rmtree(samples_dir)

os.makedirs(samples_dir)

tmp_info_file = os.path.join(samples_dir, "info_tmp.dat")
output_info_file = os.path.join(samples_dir, "info.dat")

output_vec_file = os.path.join(samples_dir, "info.vec")

#------------------------------------------------------------
#--------------------CREATE SAMPLES--------------------------
#------------------------------------------------------------

cmd_template = "opencv_createsamples -img {} -bg {} -info {} -num {} -pngout -w 20 -h 20 -bgcolor 255"

for img_line in pos_images:
    
    pos_img = img_line.split(" ")[0]
    img_path = os.path.join(subsystem_path, "pos", pos_img)
    
    num_samples = min(args.num - num_created, samples_per)
    num_created += num_samples

    cmd_str = cmd_template.format(img_path, neg_index, tmp_info_file, num_samples)   

    subprocess.call(shlex.split(cmd_str))

    with open(tmp_info_file, 'r') as f:
        data = f.read()

    with open(output_info_file, 'a') as f:
        f.write(data)

vec_cmd_str = "opencv_createsamples -info {} -vec {} -num {} -pngout -w 20 -h 20 -bgcolor 255".format(output_info_file, output_vec_file, num_created)
subprocess.call(shlex.split(vec_cmd_str))