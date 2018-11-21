#!/bin/bash
set -x -e

# AWS EMR step script 
# for installing Superset on AWS EMR 5+
#
# 2018-03-08 - Tom Zeng tomzeng@amazon.com, initial version
# 2018-11-10 - Tom Zeng tomzeng@amazon.com, updated for the latest superset

# check for master node
IS_MASTER=false
if grep isMaster /mnt/var/lib/info/instance.json | grep true;
then
  IS_MASTER=true
fi

# error message
error_msg ()
{
  echo 1>&2 "Error: $1"
}

# some defaults
SUPERSET_PORT=8082
SUPERSET_USERNAME='admin'
SUPERSET_PASSWORD='admin'
SUPERSET_FIRSTNAME='admin'
SUPERSET_LASTNAME='user'
SUPERSET_EMAIL='admin@example.org'
SUPERSET_LOAD_EXAMPLES=false

# get input parameters
while [ $# -gt 0 ]; do
    case "$1" in
    --port)
      shift
      SUPERSET_PORT=$1
      ;;
    --user)
      shift
      SUPERSET_USERNAME=$1
      ;;
    --password)
      shift
      SUPERSET_PASSWORD=$1
      ;;
    --load-examples)
      SUPERSET_LOAD_EXAMPLES=true
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

if [ "$IS_MASTER" = true ]; then

export PATH=/usr/local/bin:$PATH
sudo yum install -y gcc gcc-c++ libffi-devel python36 python36-devel python36-pip python-wheel openssl-devel libsasl2-devel openldap-devel
sudo python3 -m pip install --upgrade pip
#sudo mv /usr/bin/pip /usr/bin/pip-save || true
#sudo ln -s /usr/local/bin/pip /usr/bin/ || true
sudo python3 -m pip install --upgrade setuptools
  
sudo python3 -m pip install superset --ignore-installed colorama

fabmanager create-admin --app superset --username $SUPERSET_USERNAME --password $SUPERSET_PASSWORD --firstname $SUPERSET_FIRSTNAME --lastname $SUPERSET_LASTNAME --email $SUPERSET_EMAIL || true
#TODO - add support for MySQL/Postgres in addition to SQLite
superset db upgrade
if [ "$SUPERSET_LOAD_EXAMPLES" = true ]; then
  superset load_examples
fi
superset init
cd ~/.superset
sqlite3 superset.db <<SQL
INSERT INTO "dbs" VALUES(datetime('now'),datetime('now'),2,'Hive','hive://localhost:10000',1,1,NULL,NULL,'{
    "metadata_params": {},
    "engine_params": {},
    "metadata_cache_timeout": {},
    "schemas_allowed_for_csv_upload": []
}
',0,1,1,'',0,1,1,'[Hive].(id:2)',NULL,1,1,1);
INSERT INTO "dbs" VALUES(datetime('now'),datetime('now'),3,'Spark','hive://localhost:10001',1,1,NULL,NULL,'{
    "metadata_params": {},
    "engine_params": {},
    "metadata_cache_timeout": {},
    "schemas_allowed_for_csv_upload": []
}
',0,1,1,'',0,1,1,'[Spark].(id:3)',NULL,1,1,1);
INSERT INTO "dbs" VALUES(datetime('now'),datetime('now'),4,'Presto','presto://localhost:8889/hive/default',1,1,NULL,NULL,'{
    "metadata_params": {},
    "engine_params": {},
    "metadata_cache_timeout": {},
    "schemas_allowed_for_csv_upload": []
}
',0,1,1,'',0,1,1,'[Presto].(id:4)',NULL,1,1,1);
SQL

sudo -u spark /usr/lib/spark/sbin/start-thriftserver.sh &
#TODO - replace the following with setting up and running superset as a service 
superset runserver -p ${SUPERSET_PORT} &
fi
