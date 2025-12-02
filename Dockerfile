# Step 1: Platform Selection | BASE IMAGE
FROM ubuntu:24.04
LABEL key="j-huancaborges"

# Critical for Ubuntu 22.04 to prevent "Timezone" interactive prompts
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Step 2: System Updates & Basic Tools
RUN apt-get update && apt-get -y upgrade && \
    apt-get -y install --no-install-recommends \
    sudo \
    curl \
    vim \
    nano \
    wget \
    tar \
    rsync \
    tree \
    openssh-server \
    pdsh \
    apache2 \
    mysql-server \
    mysql-client \
    software-properties-common \
    build-essential  \
    iputils-ping \
    net-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# # Step 3: Java Installation (OpenJDK 11)
# RUN add-apt-repository universe && \
#     apt-get update && \
#     apt-get -y install openjdk-11-jdk && \
#     apt-get clean

# # Create the symlink expected by your env files
# RUN ln -s /usr/lib/jvm/java-11-openjdk-amd64 /usr/lib/jvm/java-1.11.0

# Step 3: Java Installation (OpenJDK 8)
RUN add-apt-repository universe && \
    apt-get update && \
    apt-get -y install openjdk-8-jdk && \
    apt-get clean

# Create the symlink expected by your env files
RUN ln -s /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/java-1.8.0

# Step 4: User Configuration (Docker User)
RUN adduser --disabled-password --gecos '' docker && \
    adduser docker sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER root


# Step 5: SSH CONFIGURATION
# Ubuntu 24.04 disables RSA by default. We enable it and set keys.
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/authorized_keys

# ESSENTIAL ENV VARS FOR BIG DATA STACK
ENV JAVA_HOME="/usr/lib/jvm/java-1.8.0"
ENV HADOOP_HOME="/hadoop"
ENV PIG_HOME="/pig"
ENV HIVE_HOME="/hive"
ENV HCAT_HOME="/hive/hcatalog"
ENV SPARK_HOME="/spark"
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
ENV HADOOP_MAPRED_HOME=$HADOOP_HOME


# Step 6: DOWNLOAD + INSTALL BIG DATA STACK
# ----- HADOOP 3.4.1 -----
#COPY resources/hadoop-3.4.1.tar.gz /
RUN wget --no-check-certificate -q https://dlcdn.apache.org/hadoop/common/hadoop-3.4.1/hadoop-3.4.1.tar.gz && \
    tar -xzf hadoop-3.4.1.tar.gz && \
    rm hadoop-3.4.1.tar.gz && \
    ln -sf /hadoop-3.4.1 $HADOOP_HOME

# ----- HIVE 3.1.3 -----
#COPY resources/apache-hive-3.1.3-bin.tar.gz /
RUN wget --no-check-certificate -q https://archive.apache.org/dist/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz && \
    tar -xzf apache-hive-3.1.3-bin.tar.gz && \
    rm apache-hive-3.1.3-bin.tar.gz  && \
    ln -sf /apache-hive-3.1.3-bin $HIVE_HOME

# ----- PIG 0.18.0 -----
#COPY resources/pig-0.18.0.tar.gz /
RUN wget --no-check-certificate -q https://dlcdn.apache.org/pig/pig-0.18.0/pig-0.18.0.tar.gz && \
    tar -xzf pig-0.18.0.tar.gz && \
    rm pig-0.18.0.tar.gz && \
    ln -sf /pig-0.18.0 $PIG_HOME

# ----- SPARK 3.5.7 -----
#COPY resources/spark-3.5.7-bin-hadoop3.tgz /
RUN wget --no-check-certificate -q https://dlcdn.apache.org/spark/spark-3.5.7/spark-3.5.7-bin-hadoop3.tgz && \
    tar -xzf spark-3.5.7-bin-hadoop3.tgz && \
    rm spark-3.5.7-bin-hadoop3.tgz && \
    ln -sf /spark-3.5.7-bin-hadoop3 $SPARK_HOME

#  ----- MYSQL CONNECTOR ----- 
RUN wget -q https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.2.0/mysql-connector-j-8.2.0.jar -O $HIVE_HOME/lib/mysql-connector-j-8.2.0.jar


# Step 7: GROUPS & USERS FOR PERMISSIONS
RUN addgroup hadoop && \
    adduser --ingroup hadoop --gecos "" --disabled-password hadoop && \
    addgroup hive && \
    adduser --ingroup hive --gecos "" --disabled-password hive && \
    usermod -a -G hadoop hive


# Step 8: COPY ALL CONFIGIGURATION FILES
# RUN mkdir -p /conf
COPY conf/core-site.xml $HADOOP_CONF_DIR/
COPY conf/hdfs-site.xml $HADOOP_CONF_DIR/
COPY conf/hadoop-env.sh $HADOOP_CONF_DIR/
COPY conf/yarn-site.xml $HADOOP_CONF_DIR/
COPY conf/mapred-site.xml $HADOOP_CONF_DIR/
COPY conf/hive-site.xml $HIVE_HOME/conf/
COPY conf/spark-env.sh $SPARK_HOME/conf/
COPY conf/spark-defaults.conf $SPARK_HOME/conf/
COPY bootstrap.sh /bootstrap.sh

# Make bootstrap executable
RUN chmod +x /bootstrap.sh


# Step 9: EXPOSE PORTS
# HDFS
EXPOSE 1004 1006 8020 9867 9870 9864 50470 9000 50070
# YARN
EXPOSE 8030 8031 8032 8033 8040 8041 8042 8088 10020 19888
# HDFS datnode
EXPOSE 9866
# MySQL/SSH/SOCKS
EXPOSE 3306 22 1180 

# HIVE PORTS (STANDARDIZED)
# 9083: Metastore (Interno/Thrift)
# 10000: HiveServer2 (JDBC/ODBC - Conexión externa)
# 10002: HiveServer2 Web UI
EXPOSE 9083 10000 10002

# spark UI port
EXPOSE 4040
