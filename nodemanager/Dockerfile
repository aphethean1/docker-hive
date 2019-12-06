FROM bde2020/hadoop-nodemanager:2.0.0-hadoop2.7.4-java8

WORKDIR /opt
ENV SPARK_HOME /opt/spark

# Use older deb repository https://unix.stackexchange.com/questions/508724/failed-to-fetch-jessie-backports-repository
RUN cat /etc/apt/apt.conf.d/70debconf \
    && echo "Acquire::Check-Valid-Until \"false\";" >> /etc/apt/apt.conf.d/70debconf \
	&& cat /etc/apt/apt.conf.d/70debconf

RUN cd /var/lib/apt/lists/ \
    && rm -fr * \
    && cd /etc/apt/sources.list.d/ \
    && rm -fr * \
    && cd /etc/apt \
    && cp sources.list sources.list.old \
    && rm sources.list \
    && echo "deb http://cdn-fastly.deb.debian.org/debian/ jessie main" >> sources.list \
    && echo "deb http://security.debian.org/ jessie/updates main" >> sources.list \
    && echo "deb http://archive.debian.org/debian jessie-backports main" >> sources.list \
    && apt-get clean \
    && apt-get update
	
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      python-software-properties dos2unix wget
	
# Install Spark and python
RUN wget http://apache.mirror.anlx.net/spark/spark-2.3.4/spark-2.3.4-bin-hadoop2.7.tgz && \
	tar -xzvf spark-2.3.4-bin-hadoop2.7.tgz && \
	mv spark-2.3.4-bin-hadoop2.7 spark

# Install spark_shuffle jar
RUN cp /opt/spark/yarn/spark-2.3.4-yarn-shuffle.jar /opt/hadoop-2.7.4/share/hadoop/yarn/lib/

RUN	apt-get clean && \
	rm -rf /var/lib/apt/lists/*


# Add our updated entrypoint.sh with fix for a yarn property with an underscore
ADD entrypoint.sh /entrypoint.sh
RUN dos2unix /entrypoint.sh && chmod +x /entrypoint.sh
