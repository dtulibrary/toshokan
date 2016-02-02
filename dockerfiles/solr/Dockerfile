FROM solr:5.3
ADD solr-conf /solr-conf
ADD solr-lib /opt/solr/server/solr/lib
ADD fixtures /solr-fixtures
WORKDIR /opt/solr/bin
RUN sed -i -e 's/^"$JAVA" -classpath/exec \0/' post
RUN ./solr start -m "1024m"; \
    ./solr create -c metastore -d /solr-conf/metastore/conf -p 8983; \
    ./solr create -c toc -d /solr-conf/toc/conf -p 8983; \
    ./post -c metastore /solr-fixtures/metastore.xml; \
    ./post -c toc /solr-fixtures/toc.xml; \
    ./solr stop
CMD exec /opt/solr/bin/solr start -f
