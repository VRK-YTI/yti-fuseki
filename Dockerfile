FROM java:8-jre-alpine
RUN apk add --update pwgen bash wget ca-certificates && rm -rf /var/cache/apk/*

# Fuseki 3.6.0
#ENV FUSEKI_SHA1 22db12165b820e05f07bee5688c22db04b521467
#ENV FUSEKI_VERSION 3.6.0

# Fuseki 2.3.0
ENV FUSEKI_SHA1 c2513b30a08ba284a4d71c587b9fc51e10f632ac
ENV FUSEKI_VERSION 2.3.0

ENV FUSEKI_MIRROR http://www.eu.apache.org/dist/
ENV FUSEKI_ARCHIVE http://archive.apache.org/dist/

VOLUME /fuseki
ENV FUSEKI_BASE /fuseki
ENV FUSEKI_HOME /jena-fuseki

WORKDIR /tmp
RUN echo "$FUSEKI_SHA1  fuseki.tar.gz" > fuseki.tar.gz.sha1
RUN     wget -O fuseki.tar.gz $FUSEKI_MIRROR/jena/binaries/apache-jena-fuseki-$FUSEKI_VERSION.tar.gz || \
        wget -O fuseki.tar.gz $FUSEKI_ARCHIVE/jena/binaries/apache-jena-fuseki-$FUSEKI_VERSION.tar.gz && \
        sha1sum -c fuseki.tar.gz.sha1 && \
        tar zxf fuseki.tar.gz && \
        mv apache-jena-fuseki* $FUSEKI_HOME && \
        rm fuseki.tar.gz* && \
        cd $FUSEKI_HOME && rm -rf fuseki.war

COPY log4j.properties /jena-fuseki/log4j.properties
COPY shiro.ini /jena-fuseki/shiro.ini
COPY config.ttl /jena-fuseki/config.ttl
COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh

COPY load.sh /jena-fuseki/
COPY tdbloader /jena-fuseki/
RUN chmod 755 /jena-fuseki/load.sh /jena-fuseki/tdbloader

WORKDIR /jena-fuseki
EXPOSE 3030
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/jena-fuseki/fuseki-server", "--config=config.ttl"]
