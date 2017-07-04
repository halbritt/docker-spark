FROM openjdk:8

# Add Tini init
ENV TINI_VERSION v0.14.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

#ARG DISTRO_LOC=https://d3kbcqa49mib13.cloudfront.net/spark-2.1.1-bin-hadoop2.7.tgz
ARG DISTRO_LOC=http://172.17.0.2:9000/spark/spark-2.1.1-bin-hadoop2.7.tgz
ARG DISTRO_NAME=spark-2.1.1-bin-hadoop2.7

#
# apt update and then some packages
#
RUN apt-get update \
 && apt-get install -y --force-yes --no-install-recommends \
 # utf8 support
 locales \
 curl \
 # pyspark likes python3
 python3 \
 python3-pip \
 python3-setuptools \
 && dpkg-reconfigure -f noninteractive locales \
 && locale-gen C.UTF-8 \
 && /usr/sbin/update-locale LANG=C.UTF-8 \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 # pyspark needs py4j
 && pip3 install py4j \
 # make tini executable
 && chmod +x /tini \
 # set DNS cache TTL for Java to something other than infinity
 && echo "networkaddress.cache.ttl=60" >> $JAVA_HOME/jre/lib/security/java.security \
 && cd /opt \
 && curl $DISTRO_LOC | tar -zx \
 && ln -s $DISTRO_NAME spark \
 && cd /opt/spark/jars \
 && curl https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar -O \
 && curl http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.3/hadoop-aws-2.7.3.jar -O 
 
ENV LC_ALL en_US.UTF-8

# http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
ENV PYTHONHASHSEED 0
ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

USER root

#RUN cd /opt && \
#curl $DISTRO_LOC | tar -zx && \
# ln -s $DISTRO_NAME spark

ENTRYPOINT ["/tini", "--"]
WORKDIR /opt/spark
CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]
