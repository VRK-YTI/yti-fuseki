FROM yti-docker-java-base:corretto-17.0.10
RUN apk add --update pwgen bash wget ca-certificates && rm -rf /var/cache/apk/*

# Fuseki 4.10.0
ENV FUSEKI_SHA512 a4be52cc5f7f8767e362f893f28721f2887a3544ed779cd58fe0b32733575d97411b5a3bc2243995d6408e545bdefc5ab41c00b2c5d074df1dc0ca5063db5f83
ENV FUSEKI_VERSION 4.10.0

# Fuseki 4.6.1
# ENV FUSEKI_SHA512 12a7c242584fa739d0d1d2a4025267552069d8bf7b411545d0328e3cacc3bceddaac0584b405772b51464c33f695da86182a60480c72a661264677281771e700
# ENV FUSEKI_VERSION 4.6.1

ENV FUSEKI_ARCHIVE http://archive.apache.org/dist/

VOLUME /fuseki
ENV FUSEKI_BASE /fuseki
ENV FUSEKI_HOME /jena-fuseki

WORKDIR /tmp
RUN echo "$FUSEKI_SHA512  fuseki.tar.gz" > fuseki.tar.gz.sha512
RUN wget -O fuseki.tar.gz $FUSEKI_ARCHIVE/jena/binaries/apache-jena-fuseki-$FUSEKI_VERSION.tar.gz && sha512sum -c fuseki.tar.gz.sha512 && \
        tar zxf fuseki.tar.gz && \
        mv apache-jena-fuseki* $FUSEKI_HOME && \
        rm fuseki.tar.gz* && \
        cd $FUSEKI_HOME && rm -rf fuseki.war

COPY log4j2.properties /jena-fuseki/log4j2.properties
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
