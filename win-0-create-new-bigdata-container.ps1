
docker run -t --name bigdata-with-hadoop-hive-pig-spark --hostname hadoop -P -p9866:9866 -p10000:10000 -p10001:10001 -p10002:10002 -p8088:8088 -p9000:9000 -p9870:9870 -p8000:8000 -p3306:3306 -p50070:50070 -p50030:50030 -p4040:4040 -it -d bigdata-with-hadoop-hive-pig-spark /bin/bash -c "/bootstrap.sh >/tmp/boostrap.log"


