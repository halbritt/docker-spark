FROM openjdk:8

# set DNS cache TTL for Java to something other than infinity
RUN echo "networkaddress.cache.ttl=60" >> $JAVA_HOME/jre/lib/security/java.security



# Get R repo key and add R Repo
RUN apt-key adv --keyserver keys.gnupg.net --recv-key 'E19F5F87128899B192B1A2C2AD5F960A256A04AF' \
 && echo "deb http://cran.r-project.org/bin/linux/debian jessie-cran34/" > /etc/apt/sources.list.d/cran_r_project.list \
#
# look at all this good stuff, bloat?  what bloat?
#
 && apt-get update \
 && apt-get install -y --force-yes --no-install-recommends \
 locales \
 curl \ 
 python3 \
 python3-pip \
 python3-setuptools \
 r-base \
 r-base-dev \
 r-recommended \
 && dpkg-reconfigure -f noninteractive locales \
 && locale-gen C.UTF-8 \
 && /usr/sbin/update-locale LANG=C.UTF-8 \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 #&& pip3 install py4j

# Users with other locales should set this in their derivative image
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Add Tini
ENV TINI_VERSION v0.14.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

# http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
ENV PYTHONHASHSEED 0
ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

# spark env
ENV SPARK_DAEMON_JAVA_OPTS "-Djava.net.preferIPv4Stack=true \
 -Dcom.amazonaws.services.s3.enableV4=true" \
 -XX:+UnlockExperimentalVMOptions \
 -XX:+UseCGroupMemoryLimitForHeap" 

USER root

#ARG DISTRO_LOC=https://d3kbcqa49mib13.cloudfront.net/spark-2.1.1-bin-hadoop2.7.tgz
ARG DISTRO_LOC=http://172.17.0.3:9000/spark/spark-2.1.1-bin-hadoop2.7.tgz
ARG DISTRO_NAME=spark-2.1.1-bin-hadoop2.7

RUN cd /opt && \
 curl $DISTRO_LOC | tar -zx && \
 ln -s $DISTRO_NAME spark

ADD https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar /opt/spark/jars/
ADD http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.3/hadoop-aws-2.7.3.jar /opt/spark/jars/

WORKDIR /opt/spark
CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]
