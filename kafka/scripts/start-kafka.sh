#!/bin/sh

if [ ! -z "$LOG_RETENTION_HOURS" ]; then
    echo "log retention hours: $LOG_RETENTION_HOURS"
    sed -r -i "s/#?(log.retention.hours)=(.*)/\1=$LOG_RETENTION_HOURS/g" $KAFKA_HOME/config/server.properties
fi
if [ ! -z "$LOG_RETENTION_BYTES" ]; then
    echo "log retention bytes: $LOG_RETENTION_BYTES"
    sed -r -i "s/#?(log.retention.bytes)=(.*)/\1=$LOG_RETENTION_BYTES/g" $KAFKA_HOME/config/server.properties
fi

if [ ! -z "$NUM_PARTITIONS" ]; then
    echo "default number of partition: $NUM_PARTITIONS"
    sed -r -i "s/#?(num.partitions)=(.*)/\1=$NUM_PARTITIONS/g" $KAFKA_HOME/config/server.properties
fi

if [ ! -z "$AUTO_CREATE_TOPICS" ]; then
    echo "auto.create.topics.enable: $AUTO_CREATE_TOPICS"
    if grep -r -q "^#\?auto.create.topics.enable" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s/#?(auto.create.topics.enable)=(.*)/\1=$AUTO_CREATE_TOPICS/g" $KAFKA_HOME/config/server.properties
    else
        echo "auto.create.topics.enable=$AUTO_CREATE_TOPICS" >> $KAFKA_HOME/config/server.properties
    fi
fi

if [ ! -z "$ADVERTISED_LISTENERS" ]; then
    echo "advertised.listeners: ${ADVERTISED_LISTENERS}"
    if grep -r -q "^#\?advertised.listeners=" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s|^#?(advertised.listeners)=(.*)|\1=${ADVERTISED_LISTENERS}|g" $KAFKA_HOME/config/server.properties
    else
        echo "advertised.listeners=${ADVERTISED_LISTENERS}" >> $KAFKA_HOME/config/server.properties
    fi
fi

if [ ! -z "$LISTENERS" ]; then
    echo "listeners: ${LISTENERS}"
    if grep -r -q "^#\?listeners=" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s|^#?(listeners)=(.*)|\1=${LISTENERS}|g" $KAFKA_HOME/config/server.properties
    else
        echo "listeners=${LISTENERS}" >> $KAFKA_HOME/config/server.properties
    fi
fi

if [ ! -z "$SECURITY_PROTOCOL_MAP" ]; then
    echo "listener.security.protocol.map: ${SECURITY_PROTOCOL_MAP}"
    if grep -r -q "^#\?listener.security.protocol.map=" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s/^#?(listener.security.protocol.map)=(.*)/\1=${SECURITY_PROTOCOL_MAP}/g" $KAFKA_HOME/config/server.properties
    else
        echo "listener.security.protocol.map=${SECURITY_PROTOCOL_MAP}" >> $KAFKA_HOME/config/server.properties
    fi
fi

if [ ! -z "$INTER_BROKER" ]; then
    echo "inter.broker.listener_name: ${INTER_BROKER}"
    if grep -r -q "^#\?inter.broker.listener.name=" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s/^#?(inter.broker.listener.name)=(.*)/\1=${INTER_BROKER}/g" $KAFKA_HOME/config/server.properties
    else
        echo "inter.broker.listener.name=${INTER_BROKER}" >> $KAFKA_HOME/config/server.properties
    fi
fi

if echo "$SECURITY_PROTOCOL_MAP" | grep -r -q ":SSL"; then
    if [ -z "$SSL_PASSWORD" ]; then
        SSL_PASSWORD=`date +%s | sha256sum | base64 | head -c 32`
    fi
    if [ ! -z "$SSL_CERT" ]; then
        mkdir -p /var/private/ssl/server/
        echo "${SSL_CERT}" >> /var/private/ssl/server/cert.pem
        openssl x509 -outform der -in /var/private/ssl/server/cert.pem -out /var/private/ssl/server/cert.der
        ${JAVA_HOME}/bin/keytool -import -alias localhost -keystore /var/private/ssl/server.keystore.jks -file /var/private/ssl/server/cert.der -noprompt --storepass ${SSL_PASSWORD} --keypass ${SSL_PASSWORD}
    else
        ${JAVA_HOME}/bin/keytool -genkey -noprompt -alias localhost -dname "${SSL_DN}" -keystore /var/private/ssl/server.keystore.jks --storepass ${SSL_PASSWORD} --keypass ${SSL_PASSWORD}
    fi
    echo "ssl.keystore.location=/var/private/ssl/server.keystore.jks" >> $KAFKA_HOME/config/server.properties
    echo "ssl.keystore.password=${SSL_PASSWORD}" >> $KAFKA_HOME/config/server.properties
    echo "ssl.key.password=${SSL_PASSWORD}" >> $KAFKA_HOME/config/server.properties
fi

export EXTRA_ARGS='-name kafkaServer'
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
