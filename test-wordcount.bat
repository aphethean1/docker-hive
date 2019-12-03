SET DOCKER_NETWORK=docker-hive_default
SET ENV_FILE=hadoop-hive.env
SET CURRENT_BRANCH=master

IF %1 == a GOTO client

GOTO end

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
docker run --network %DOCKER_NETWORK% --env-file %ENV_FILE% hadoop-wordcount
docker run --network %DOCKER_NETWORK% --env-file %ENV_FILE% bde2020/hadoop-base:%CURRENT_BRANCH% hdfs dfs -cat /output/*
docker run --network %DOCKER_NETWORK% --env-file %ENV_FILE% bde2020/hadoop-base:%CURRENT_BRANCH% hdfs dfs -rm -r /output
docker run --network %DOCKER_NETWORK% --env-file %ENV_FILE% bde2020/hadoop-base:%CURRENT_BRANCH% hdfs dfs -rm -r /input

GOTO end

:client
  ECHO docker run -it --network %DOCKER_NETWORK% --env-file %ENV_FILE% -v %CD%/local:/local bde2020/hadoop-base:%CURRENT_BRANCH% /bin/bash


:end
