#!/bin/bash

eg='\033[0;32m'
enc='\033[0m'
echoe () {
    OIFS=${IFS}
    IFS='%'
    echo -e $@
    IFS=${OIFS}
}

gprn() {
    echoe "${eg} >> ${1}${enc}"
}

### Setup ENV variables
# Hadoop Users (Running as root for Docker simplicity)
export HDFS_NAMENODE_USER="root"
export HDFS_SECONDARYNAMENODE_USER="root"
export HDFS_DATANODE_USER="root"
export YARN_RESOURCEMANAGER_USER="root"
export YARN_NODEMANAGER_USER="root"
export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$PIG_HOME/bin/*:$HIVE_HOME/bin/*

## Add environment to bashrc for interactive usage
cat <<EOT >> ~/.bashrc
export JAVA_HOME="/usr/lib/jvm/java-1.8.0"
export HADOOP_HOME="/hadoop"
export HADOOP_CONF_DIR="/hadoop/etc/hadoop"
export HADOOP_MAPRED_HOME="/hadoop"
export PIG_HOME="/pig"
export HIVE_HOME="/hive"
export HCAT_HOME="/hive/hcatalog"
export SPARK_HOME="/spark"
export HADOOP_CLASSPATH="\$HADOOP_CLASSPATH:\$PIG_HOME/bin/*:\$HIVE_HOME/bin/*"
export PATH="\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$PIG_HOME/bin:\$HIVE_HOME/bin"
EOT


# -------------------------------------------------------
# Service Startup
# -------------------------------------------------------

gprn "Starting SSH..."
service ssh start
# Evita el error de "Host key verification failed" en localhost
if [ ! -f ~/.ssh/known_hosts ]; then
    ssh-keyscan localhost >> ~/.ssh/known_hosts
    ssh-keyscan hadoop >> ~/.ssh/known_hosts
    ssh-keyscan 0.0.0.0 >> ~/.ssh/known_hosts
fi

gprn "Starting MySQL..."
# We need to ensure the permissions are correct for MySQL 8
usermod -d /var/lib/mysql/ mysql
service mysql start
sleep 5

FLAG="/var/lib/mysql/.initialized"
# Verificar si el archivo de marcador existe
if [ ! -f "$FLAG" ]; then
    gprn "Configuring MySQL Users..."
    # Fix for MySQL 8.0 authentication
    mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';"
    mysql -uroot -p'root' -e "CREATE USER IF NOT EXISTS 'hive'@'localhost' IDENTIFIED WITH mysql_native_password BY 'hive';"
    mysql -uroot -p'root' -e "GRANT ALL PRIVILEGES ON *.* TO 'hive'@'localhost';"
    mysql -uroot -p'root' -e "CREATE USER IF NOT EXISTS 'hive'@'%' IDENTIFIED WITH mysql_native_password BY 'hive';"
    mysql -uroot -p'root' -e "GRANT ALL PRIVILEGES ON *.* TO 'hive'@'%';"
    mysql -uroot -p'root' -e "FLUSH PRIVILEGES;"
    
    # Marcar que la inicialización se ha completado
    touch "$FLAG"
    gprn "MySQL authentication initialization completed."
else
    gprn "MySQL has already been authentication initialized. Skipping."
fi

# Format NameNode (Only if not already formatted)
if [ ! -d "/tmp/hadoop-root/dfs/name" ]; then
    gprn "Formatting NameNode..."
    $HADOOP_HOME/bin/hdfs namenode -format
else
    gprn "NameNode already formatted. Skipping..."
fi

gprn "Starting HDFS..."
$HADOOP_HOME/sbin/start-dfs.sh

gprn "Starting YARN..."
$HADOOP_HOME/sbin/start-yarn.sh

gprn "Starting JobHistoryServer..."
$HADOOP_HOME/bin/mapred --daemon start historyserver

#jps

gprn "Initializing Hive Metastore Schema..."
$HIVE_HOME/bin/schematool -userName hive -passWord 'hive' -dbType mysql -initSchema

gprn "Starting Hive Metastore... (Standard Port: 9083)"
$HIVE_HOME/bin/hive --service metastore > /tmp/hive_metastore.log 2>&1 &

gprn "Waiting for Metastore to allow connections..."
sleep 20

gprn "Starting HiveServer2... (Standard Port: 10000)"
$HIVE_HOME/bin/hive --service hiveserver2 --hiveconf hive.execution.engine=mr > /tmp/hiveserver2.log 2>&1 &

hdfs dfs -chmod -R 777 /tmp
# Spark
#gprn "Starting Spark Master... (Port: 7077, Web UI: 8080)"
#$SPARK_HOME/sbin/start-master.sh
#gprn "Starting Spark Worker... (Connected to Master)"
#$SPARK_HOME/sbin/start-worker.sh spark://localhost:7077

gprn "Services Started."
jps
gprn "HiveServer2 is available at localhost:10000 (JDBC)"
gprn "Metastore is available at localhost:9083 (Thrift)"

# Keep container running
tail -f /dev/null