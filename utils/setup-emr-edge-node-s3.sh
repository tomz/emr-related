#!/bin/bash

# AWS EMR edge node setup script (tested for Amazon Linux and Ubuntu)
# Pre-reqs:
#   1. the emr client dependencies generated with the step s3://tomzeng/BAs/copy-emr-client-deps.sh
#   2. the edge node has Python, JDK 8, AWS CLI, and Ruby installed
#   3. python on the edge node should be the same version as pyspark on EMR (2.7 or 3.4), conda can be used
#   4. this script is copied to edge node by running "aws s3 cp s3://tomzeng/BAs/setup-emr-edge-node-s3.sh ."

# Usage: bash setup-emr-edge-node-s3.sh --emr-client-deps <EMR client dependencies file in S3>
#
# Example: bash setup-emr-edge-node-s3.sh --emr-cient-deps s3://tomzeng-perf2/emr-client-deps/emr-client-deps-j-2WRQJIKRMUIMN.tar.gz

# 2018-03-27 - Tom Zeng tomzeng@amazon.com, initial version


EMR_CLIENT_DEPS=""

# error message
error_msg ()
{
  echo 1>&2 "Error: $1"
}

# get input parameters
while [ $# -gt 0 ]; do
    case "$1" in
    --emr-client-deps)
      shift
      EMR_CLIENT_DEPS=$1
      ;;
    -*)
      # do not exit out, just note failure
      error_msg "unrecognized option: $1"
      ;;
    *)
      break;
      ;;
    esac
    shift
done

aws s3 cp $EMR_CLIENT_DEPS .
EMR_CLIENT_DEPS_LOCAL=$(ruby -e "s3file='$EMR_CLIENT_DEPS'.split('/').last;puts s3file")

tar xvfz $EMR_CLIENT_DEPS_LOCAL
cd emr-client-deps
sudo mv usr/bin/* /usr/bin || true
sudo mv usr/lib/* /usr/lib || true

sudo mkdir -p /etc/hadoop
sudo mkdir -p /etc/hive
sudo mkdir -p /etc/spark
sudo ln -s /usr/lib/hadoop/etc/hadoop /etc/hadoop/conf
sudo ln -s /usr/lib/hive/conf /etc/hive/
sudo ln -s /usr/lib/spark/conf /etc/spark/

sudo mv etc/presto /etc || true

sudo mv etc/tez /etc || true
cd ..
rm -rf emr-client-deps
rm $EMR_CLIENT_DEPS_LOCAL

sudo ln -s /tmp /mnt/ || true

# set up user hadoop, additional users can be set up similarly
sudo adduser hadoop
sudo mkdir -p /var/log/hive/user/hadoop
sudo chown hadoop:hadoop /var/log/hive/user/hadoop

# install Oracle JDK if needed, need to check for existing Java install, and also make it non-interactive
# Ubuntu
#sudo apt-get install python-software-properties
#sudo add-apt-repository ppa:webupd8team/java
#sudo apt-get update
#sudo apt-get install oracle-java8-installer
#
# Amazon Linux
#aws s3 cp s3://tomzeng/jdk/jdk-8u161-linux-x64.tar.gz .
#sudo mv jdk-8u161-linux-x64.tar.gz /opt/
#cd /opt
#sudo tar xzf jdk-8u161-linux-x64.tar.gz
#cd jdk1.8.0_161
#sudo alternatives --install /usr/bin/java java /opt/jdk1.8.0_161/bin/java 2
#sudo alternatives --config java
#export JAVA_HOME=/opt/jdk1.8.0_161


# testing the egde node:

#sudo su - hadoop

# optionally use conda to set up python env using the same version of python for pyspark
#conda create --name emr-py3 python=3.4
#source activate emr-py3

# set the python to the same version on EMR, needed on Ubuntu 16, but not needed on Ubuntu 14
#export PYSPARK_PYTHON=python3.4
#export PYSPARK_DRIVER_PYTHON=python3.4

# this might be needed for openjdk:
#export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64

# examples
#hadoop-mapreduce-examples pi 10 10000
#spark-submit /usr/lib/spark/examples/src/main/python/pi.py
#presto-cli --catalog hive --schema default
#hive

echo "Finished copy EMR edge node client dependencies"
