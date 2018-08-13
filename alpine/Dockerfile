FROM openjdk:8-alpine
MAINTAINER Heath Albritton halbritt@gmail.com

ENV LC_ALL en_US.UTF-8 \
    PYTHONHASHSEED 0 \
    PYTHONIOENCODING UTF-8 \
    PIP_DISABLE_PIP_VERSION_CHECK 1 \
    SPARK_HOME=/opt/spark \
    PYSPARK_PYTHON=python2.7

#ARG
ARG SPARK_PACKAGE=spark-2.3.1-bin-hadoop2.7
ARG SPARK_URL=https://d3kbcqa49mib13.cloudfront.net
ARG SPARK_URL=http://mirror.olnevhost.net/pub/apache/spark/spark-2.3.1/

RUN apk --no-cache upgrade \
    && apk --no-cache add bash \
    curl \
    python \
    py-pip \
    tar \
    tini \
    && pip install py4j \
    # set DNS cache TTL for Java to something other than infinity
    && echo "networkaddress.cache.ttl=60" >> $JAVA_HOME/jre/lib/security/java.security \
    && mkdir /opt \
    && cd /opt \
    && curl -sL --retry 3 \
    $SPARK_URL/$SPARK_PACKAGE.tgz | tar -zx \
    && ln -s $SPARK_PACKAGE spark \
    && cd /opt/spark/jars \
    && curl -sL --retry 3 \
    https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar -O \
    && curl -sL --retry 3 \
    http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.3/hadoop-aws-2.7.3.jar -O

USER root

ENTRYPOINT ["/sbin/tini", "--"]
WORKDIR /opt/spark
CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]
