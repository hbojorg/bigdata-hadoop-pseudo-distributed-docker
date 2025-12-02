# Set Hadoop-specific environment variables here.

# The java implementation to use.
export JAVA_HOME="/usr/lib/jvm/java-1.8.0"

# Heap Size Configs
export HADOOP_HEAPSIZE=1024
export HDFS_NAMENODE_OPTS="-Xmx512m"
#export HADOOP_NAMENODE_OPTS="-Xmx512m"
export HADOOP_OPTS="-Xmx256m"
#export YARN_OPTS="-Xmx256m"

# Hadoop 3.4 on Ubuntu 22.04 Specifics
export HADOOP_OS_TYPE=${HADOOP_OS_TYPE:-$(uname -s)}

# This prevents the "rsh: connection refused" error
export PDSH_RCMD_TYPE=ssh

# Standard SSH Port
export HADOOP_SSH_OPTS="-p 22"

# Run as root (Required for Docker sandbox environments)
export HDFS_NAMENODE_USER="root"
export HDFS_DATANODE_USER="root"
export HDFS_SECONDARYNAMENODE_USER="root"
export YARN_RESOURCEMANAGER_USER="root"
export YARN_NODEMANAGER_USER="root"