#!/usr/bin/env bash

# This script sets up a conda environment to run TensorFlow on the GZK nodes.

# Created by Sam Gelman (sgelman2@wisc.edu) with help from Jay Wang (zwang688@wisc.edu) and Shengchao Liu (shengchao.liu@wisc.edu)

# echo some HTCondor job information
echo _CONDOR_JOB_IWD $_CONDOR_JOB_IWD
echo Cluster $cluster
echo Process $process
echo RunningOn $runningon

# this makes it easier to set up the environments, since the PWD we are running in is not $HOME
export HOME=$PWD

# set up miniconda and add it to path
bash Miniconda3-latest-Linux-x86_64.sh -b -p ~/miniconda3 > /dev/null
export PATH=$PATH:~/miniconda3/bin

# set up a conda environment
conda create --yes --name my-conda-environment python=3.5
source activate my-conda-environment

# install cudatoolkit and cudnn
conda install -c anaconda cudatoolkit==8.0 --yes
conda install -c anaconda cudnn==6.0.21 --yes

# install tensorflow and other libraries for machine learning
pip install tensorflow-gpu==1.4
pip install numpy scipy scikit-learn pandas matplotlib seaborn
pip install Pillow 
pip install keras
# set up custom libc environment (see http://goo.gl/6iVTDZ)
mkdir my_libc_env
tar -xzf libc.tar.gz -C my_libc_env
cd my_libc_env
ar p libc6_2.17-0ubuntu5_amd64.deb data.tar.gz | tar zx
ar p libc6-dev_2.17-0ubuntu5_amd64.deb data.tar.gz | tar zx
rpm2cpio libstdc++6-4.8.2-3.2.mga4.x86_64.rpm | cpio -idmv
cd ~

# set up the data and codes to run the model
unzip keras-yolo3.zip -d model
cd model
cd keras-yolo3
# download the weights of model
# wget https://pjreddie.com/media/files/yolov3.weights
echo `pwd`

# this command is required to run python + tensorflow with our custom libc environment
# https://stackoverflow.com/questions/8657908/deploying-yesod-to-heroku-cant-build-statically/8658468#8658468
$HOME/my_libc_env/lib/x86_64-linux-gnu/ld-2.17.so --library-path $LD_LIBRARY_PATH:$HOME/my_libc_env/lib/x86_64-linux-gnu/:$HOME/my_libc_env/usr/lib64/ `which python` ./train.py
ls -lh
