# Java y Hadoop
export JAVA_HOME=/usr/lib/jvm/java-1.8.0
export HADOOP_CONF_DIR=/hadoop/etc/hadoop
export YARN_CONF_DIR=/hadoop/etc/hadoop

export SPARK_LOCAL_HOSTNAME=hadoop

# Configuración para Docker/YARN (crítico para resolución de host)
export SPARK_MASTER_HOST=hadoop
export SPARK_LOCAL_IP=hadoop
export SPARK_MASTER_IP=hadoop

# Directorio temporal (importante en contenedores)
export SPARK_LOCAL_DIRS=/tmp/spark

# Directorio de logs de Spark
export SPARK_LOG_DIR=/var/log/spark
mkdir -p "$SPARK_LOG_DIR"

# Opcional: Límite de memoria (ajusta según tu contenedor)
export SPARK_EXECUTOR_MEMORY=1g
export SPARK_DRIVER_MEMORY=1g
