#!/bin/bash

# AWS EMR edge node setup script (tested for Amazon Linux and Ubuntu)
# Pre-reqs:
#   1. the edge node is set up in the same VPC subnet as the EMR master, with the same security group and key pair
#   2. the edge node has Python, JDK 8, AWS CLI installed, and the EC2 key file is copied to the edge node
#   3. python on the edge node should be the same version as pyspark on EMR (2.7 or 3.4), conda can be used
#   4. this script is copied to edge node by running "aws s3 cp s3://tomzeng/BAs/setup-emr-edge-node.sh ."

# Usage: bash setup-emr-edge-node.sh --key-file <EC2 private key file> --emr-master <EMR master hostname>
#
# Example: bash setup-emr-edge-node.sh --key-file ~/tomzeng-emr.pem --emr-master ec2-34-228-12-116.compute-1.amazonaws.com

# 2018-03-16 - Tom Zeng tomzeng@amazon.com, initial version


EMR_MASTER=""
EC2_PEM_FILE=""

# error message
error_msg ()
{
  echo 1>&2 "Error: $1"
}

# get input parameters
while [ $# -gt 0 ]; do
    case "$1" in
    --emr-master)
      shift
      EMR_MASTER=$1
      ;;
    --key-file)
      shift
      EC2_PEM_FILE=$1
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

mkdir -p usr-bin
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/presto-cli usr-bin || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/beeline usr-bin || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/emrfs usr-bin || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/emr-strace usr-bin || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/flink* usr-bin || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/hadoop* usr-bin || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/hbase usr-bin || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/hcat usr-bin || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/hdfs usr-bin || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/hive* usr-bin || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/mahout usr-bin || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/mapred usr-bin || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/oozie* usr-bin || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/pig* usr-bin || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/pyspark* usr-bin || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/spark* usr-bin || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/sqoop* usr-bin || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/yarn* usr-bin || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/bin/zoo* usr-bin || true

mkdir -p usr-lib
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/hadoop usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/hadoop usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/hive usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/spark usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/bigtop-utils usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/flink usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/hadoop-hdfs usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/hadoop-httpfs usr-lib || true
#scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/hadoop-kms usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/hadoop-lzo usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/hadoop-mapreduce usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/hadoop-yarn usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/hbase usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/hive usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/hive-hcatalog usr-lib || true
#scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/hue usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/livy usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/mahout usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/oozie usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/phoenix usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/pig usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/presto usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/spark usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/sqoop usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/tez usr-lib || true
#scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/zeppelin usr-lib || true
scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/usr/lib/zookeeper usr-lib || true

sudo mv usr-bin/* /usr/bin
sudo mv usr-lib/* /usr/lib
rm -rf usr-bin
rm -rf usr-lib

sudo mkdir -p /etc/hadoop
sudo mkdir -p /etc/hive
sudo mkdir -p /etc/spark
sudo ln -s /usr/lib/hadoop/etc/hadoop /etc/hadoop/conf
sudo ln -s /usr/lib/hive/conf /etc/hive/
sudo ln -s /usr/lib/spark/conf /etc/spark/

scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/etc/presto/conf .
sudo mkdir -p /etc/presto
sudo mv conf /etc/presto/

scp -i $EC2_PEM_FILE -pr hadoop@$EMR_MASTER:/etc/tez/conf .
sudo mkdir -p /etc/tez
sudo mv conf /etc/tez/

sudo ln -s /tmp /mnt/

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
