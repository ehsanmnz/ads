FROM java:8-jre

RUN mkdir -p /opt/divolte

RUN curl -o divolte-collector-0.5.0.tar.gz http://divolte-releases.s3-website-eu-west-1.amazonaws.com/divolte-collector/0.5.0/distributions/divolte-collector-0.5.0.tar.gz && \
    tar zxpf divolte-collector-0.5.0.tar.gz -C /opt/divolte

ADD conf/divolte-collector.conf /opt/divolte/divolte-collector-0.5.0/conf/divolte-collector.conf
RUN chown root:root /opt/divolte/divolte-collector-0.5.0/conf/divolte-collector.conf

EXPOSE 8290

CMD ["/opt/divolte/divolte-collector-0.5.0/bin/divolte-collector"]