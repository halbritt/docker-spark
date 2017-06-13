FROM openjdk:8
MAINTAINER Getty Images "https://github.com/gettyimages"

# set DNS cache TTL for Java to something other than infinity
RUN echo "networkaddress.cache.ttl=60" >> $JAVA_HOME/jre/lib/security/java.security

RUN apt-get update \
 && apt-get install -y locales \
 && dpkg-reconfigure -f noninteractive locales \
 && locale-gen C.UTF-8 \
 && /usr/sbin/update-locale LANG=C.UTF-8 \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Users with other locales should set this in their derivative image
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update \
 && apt-get install -y curl unzip \
    python3 python3-setuptools \
 && easy_install3 pip py4j \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
ENV PYTHONHASHSEED 0
ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

# spark env
ENV SPARK_DAEMON_JAVA_OPTS "-Djava.net.preferIPv4Stack=true -Dcom.amazonaws.services.s3.enableV4=true"


USER root
ARG DISTRO_LOC=https://archive.apache.org/dist/spark/spark-2.1.1/spark-2.1.1-bin-hadoop2.7.tgz
ARG DISTRO_NAME=spark-2.1.1-bin-hadoop2.7

RUN cd /opt && \
    curl $DISTRO_LOC  | \
        tar -zx && \
    ln -s $DISTRO_NAME spark

RUN curl https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar \
 -o /opt/spark/jars/aws-java-sdk-1.7.4.jar

RUN curl http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.3/hadoop-aws-2.7.3.jar \
 -o /opt/spark/jars/hadoop-aws-2.7.3.jar

WORKDIR /opt/spark
CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]
