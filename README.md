# docker-flink

## Description

This package contains files that make it usable for both Flink Job Manager as well as Flink Task Manager.  Supervisor is used to keep the flink scripts alive and running.  This package is based on `java:openjdk-8-jre-alpine` (using alpine for smaller container size).

## Arguments

```
name             default      description
SCALA_VERSION    2.11         Specifies the scala version used for the flink executable
FLINK_VERSION    1.1.3        Specifies the flink version used for the flink executable
HADOOP_VERSION   27           Specifies the hadoop version used for the flink executable.
                              Note that hadoop is not necessarily used in all flink deploys.
```

## Job Manager

To start the container as a job manager, use docker-compose like:

```yaml
flink_jobmanager:
image: relateiq/flink
expose:
  - "22"
  - "6123"
  - "8080"
  - "8081"
ports:
  - "220:22"
  - "48080:8080"
  - "48081:8081"
  - "6123:6123"
environment:
  FLINK_MANAGER_TYPE: "job"
links:
  - kafka
```

## Task Manager

To start the container as a task manager, use docker-compose like:

```yaml
flink_taskmanager:
  image: relateiq/flink
  ports:
    - "22"
  expose:
    - "6121"
    - "6122"
  environment:
    FLINK_MANAGER_TYPE: "task"
  links:
    - flink_jobmanager
    - kafka:kafka.dev.docker
```
