FROM openjdk:17-alpine@sha256:a996cdcc040704ec6badaf5fecf1e144c096e00231a29188596c784bcf858d05
RUN apk add --update pwgen bash wget ca-certificates && rm -rf /var/cache/apk/*

# Fuseki 4.6.1
ENV FUSEKI_SHA512 12a7c242584fa739d0d1d2a4025267552069d8bf7b411545d0328e3cacc3bceddaac0584b405772b51464c33f695da86182a60480c72a661264677281771e700
ENV FUSEKI_VERSION 4.6.1

# Fuseki 3.13.1
# ENV FUSEKI_SHA512 1960d3e057cdcaaa0811b33b57b86145fb0fb675eee1a6dd2d27a111313689e70ba8fa36b9ca66784cf9130ae5753bf50e32e82d9e3a7bba2786a0fc4ae7f056
# ENV FUSEKI_VERSION 3.13.1

# Fuseki 2.3.0
#ENV FUSEKI_SHA1 c2513b30a08ba284a4d71c587b9fc51e10f632ac
#ENV FUSEKI_VERSION 2.3.0

ENV FUSEKI_MIRROR http://www.eu.apache.org/dist/
ENV FUSEKI_ARCHIVE http://archive.apache.org/dist/

VOLUME /fuseki
ENV FUSEKI_BASE /fuseki
ENV FUSEKI_HOME /jena-fuseki

WORKDIR /tmp
RUN echo "$FUSEKI_SHA512  fuseki.tar.gz" > fuseki.tar.gz.sha512
RUN     wget -O fuseki.tar.gz $FUSEKI_MIRROR/jena/binaries/apache-jena-fuseki-$FUSEKI_VERSION.tar.gz || \
        wget -O fuseki.tar.gz $FUSEKI_ARCHIVE/jena/binaries/apache-jena-fuseki-$FUSEKI_VERSION.tar.gz && sha512sum -c fuseki.tar.gz.sha512 && \
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
