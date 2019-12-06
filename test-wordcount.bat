SET DOCKER_NETWORK=docker-hive_default
SET ENV_FILE=hadoop-hive.env
SET CURRENT_BRANCH=2.0.0-hadoop2.7.4-java8

rem Skip straight to running a docker container with all the hadoop client environment setup (uses hadoop-hive.env)
IF [%1] == [client] (GOTO client) ELSE (GOTO wordcount)

:wordcount
docker build -t bde2020/hadoop-base:%CURRENT_BRANCH% ./base
docker build -t bde2020/hadoop-namenode:%CURRENT_BRANCH% ./namenode
docker build -t bde2020/hadoop-datanode:%CURRENT_BRANCH% ./datanode
docker build -t bde2020/hadoop-resourcemanager:%CURRENT_BRANCH% ./resourcemanager
docker build -t bde2020/hadoop-nodemanager:%CURRENT_BRANCH% ./nodemanager
docker build -t bde2020/hadoop-historyserver:%CURRENT_BRANCH% ./historyserver
docker build -t bde2020/hadoop-submit:%CURRENT_BRANCH% ./submit


docker build -t hadoop-wordcount ./submit
docker run --network %DOCKER_NETWORK% --env-file %ENV_FILE% bde2020/hadoop-base:%CURRENT_BRANCH% hdfs dfs -mkdir -p /input/
docker run --network %DOCKER_NETWORK% --env-file %ENV_FILE% -v %CD%:/local bde2020/hadoop-base:%CURRENT_BRANCH% hdfs dfs -copyFromLocal /local/words.txt /input/

rem https://github.com/big-data-europe/docker-hadoop/blob/master/submit/Dockerfile
rem docker run --network %DOCKER_NETWORK% --env-file %ENV_FILE% hadoop-wordcount
or
docker run --network %DOCKER_NETWORK% --env-file %ENV_FILE% bde2020/hadoop-submit:%CURRENT_BRANCH%

docker run --network %DOCKER_NETWORK% --env-file %ENV_FILE% bde2020/hadoop-base:%CURRENT_BRANCH% hdfs dfs -cat /output/*
docker run --network %DOCKER_NETWORK% --env-file %ENV_FILE% bde2020/hadoop-base:%CURRENT_BRANCH% hdfs dfs -rm -r /output
docker run --network %DOCKER_NETWORK% --env-file %ENV_FILE% bde2020/hadoop-base:%CURRENT_BRANCH% hdfs dfs -rm -r /input

GOTO end

:client
  rem $ hadoop jar /local/mapred_jars/hadoop-mapreduce-examples-2.10.0.jar  pi 3 10
  rem
  rem $ hdfs dfs -mkdir -p /input/
  rem $ hdfs dfs -copyFromLocal /local/cwd/words.txt /input/
  rem $ hadoop jar /local/mapred_jars/WordCount.jar WordCount /input /output
  rem $ hdfs dfs -cat /output/*
  rem $ hdfs dfs -rm -r /output
  rem $ hdfs dfs -rm -r /input
  rem
  rem spark jars will be available with spark.yarn.archive=/local/mapred_jars/spark-libs.jar
  rem
  rem ALTERNATIVELY  (https://stackoverflow.com/questions/41112801/property-spark-yarn-jars-how-to-deal-with-it)
  rem Install spark locally, set SPARK_HOME then
  rem root@30e2f2a309e6:/# mkdir app
  rem root@30e2f2a309e6:/# cd app
  rem root@30e2f2a309e6:/app# cp /local/cwd/spark-2.3.4-bin-hadoop2.7.tgz .
  rem root@30e2f2a309e6:/app# tar -xzf spark-2.3.4-bin-hadoop2.7.tgz
  rem export SPARK_HOME=/app/spark-2.3.4-bin-hadoop2.7
  rem jar cv0f spark-libs.jar -C $SPARK_HOME/jars/ .
  rem hdfs dfs -mkdir -p /sparkjars/
  rem hdfs dfs -put spark-libs.jar /sparkjars/. 
  rem 
  rem Set spark.yarn.archive=hdfs:///sparkjars/spark-libs.jar
  rem 
  rem $ $SPARK_HOME/bin/spark-submit --conf spark.hadoop.yarn.timeline-service.enabled=false --class org.apache.spark.examples.SparkPi --master yarn --deploy-mode cluster --driver-memory 4g --executor-memory 2g --executor-cores 1 --queue thequeue $SPARK_HOME/examples/jars/spark-examples*.jar 10
  rem $ $SPARK_HOME/bin/spark-submit --conf spark.hadoop.yarn.timeline-service.enabled=false --class org.apache.spark.examples.SparkPi --master yarn --deploy-mode cluster $SPARK_HOME/examples/jars/spark-examples*.jar 10
  rem
  rem Issues:
  rem http://mail-archives.apache.org/mod_mbox/spark-issues/201807.mbox/%3CJIRA.12969978.1463399986000.13192.1531748640290@Atlassian.JIRA%3E
  rem https://www.hackingnote.com/en/spark/trouble-shooting/NoClassDefFoundError-ClientConfig
  
  docker run -it --network %DOCKER_NETWORK% --env-file %ENV_FILE% -v mapred_jars:/local/mapred_jars -v %CD%:/local/cwd bde2020/hadoop-base:%CURRENT_BRANCH% /bin/bash


:end
