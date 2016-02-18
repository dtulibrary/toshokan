#!/bin/bash

#echo "1. copy the jar file from localhost to docker solr lib..."
#cp /config/metastore-solr-plugins.jar /opt/solr/server/solr/lib/

#echo "2. restart solar?? "
#/opt/solr/bin/solr restart

echo "upload config to zookeeper..."
#/opt/solr/server/scripts/cloud-scripts/zkcli.sh -d /config/metastore/conf -cmd upconfig -s /opt/solr/server/solr -n metastore

#/opt/solr/server/scripts/cloud-scripts/zkcli.sh -d /config/toc/conf -cmd upconfig -s /opt/solr/server/solr -n toc 

echo "create collections..."
wget "http://127.0.0.1:8983/solr/admin/collections?action=CREATE&name=toc&numShards=1&replicationFactor=1"
wget "http://127.0.0.1:8983/solr/admin/collections?action=CREATE&name=metastore&numShards=1&replicationFactor=1"

echo "reload... "
wget "http://127.0.0.1:8983/solr/admin/collections?action=RELOAD&name=toc"
wget "http://127.0.0.1:8983/solr/admin/collections?action=RELOAD&name=metastore"
