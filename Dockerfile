FROM java:openjdk-8-jre-alpine

ARG SCALA_VERSION=2.11
ARG FLINK_VERSION=1.1.0
ARG HADOOP_VERSION=27

ENV FLINK_HOME /opt/flink
ENV PATH $PATH:$FLINK_HOME/bin

RUN mkdir /opt

# Dependencies
RUN apk add --no-cache supervisor bash jq

# Flink
RUN wget -q -O - $(wget -q -O - "http://www.apache.org/dyn/closer.cgi?as_json=1" | jq -r .preferred)/flink/flink-$FLINK_VERSION/flink-$FLINK_VERSION-bin-hadoop$HADOOP_VERSION-scala_$SCALA_VERSION.tgz | \
    tar -xzf - -C /opt && \
    mv /opt/flink-$FLINK_VERSION $FLINK_HOME

# See https://ci.apache.org/projects/flink/flink-docs-master/apis/best_practices.html#use-logback-when-running-flink-on-a-cluster
RUN rm $FLINK_HOME/lib/log4j-*.jar $FLINK_HOME/lib/slf4j-log4j12-*.jar && cd $FLINK_HOME/lib && \
    wget -q http://central.maven.org/maven2/ch/qos/logback/logback-core/1.1.7/logback-core-1.1.7.jar && \
    wget -q http://central.maven.org/maven2/ch/qos/logback/logback-classic/1.1.7/logback-classic-1.1.7.jar && \
    wget -q http://central.maven.org/maven2/org/slf4j/log4j-over-slf4j/1.7.21/log4j-over-slf4j-1.7.21.jar

COPY conf/* $FLINK_HOME/conf/
RUN rm $FLINK_HOME/conf/log4j.properties
ADD scripts/start-flink.sh /usr/bin/
ADD scripts/supervise-flink.sh /usr/bin/
ADD supervisor-jobmanager.ini /etc/supervisor.d/
ADD supervisor-taskmanager.ini /etc/supervisor.d/
ADD scripts/kill-supervisor.py /usr/bin/

VOLUME /tmp/flink $FLINK_HOME/conf

ENV FLINK_MANAGER_TYPE task

CMD ["/usr/bin/supervise-flink.sh"]
