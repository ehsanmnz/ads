#!/bin/sh

export EXTRA_ARGS='-name zookeeper'
$KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties