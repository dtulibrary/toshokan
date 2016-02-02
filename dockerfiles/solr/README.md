# solr_with_fixtures
Docker container with solr + fixtures for DTU metastore and toc.

## What is it?
A Docker containerization of Solr 5 with fixture data for DTU metastore configured and indexed.

## What does it do?
Builds and runs a Docker container with Solr 5 and fixture data.

## What do I need to use it?
You need Docker >= 1.9.0

## How do I use it?

### Building the container
`build.sh`

### Running the container
`run.sh`

Starts the solr5 container on IP found by
`docker inspect --format '{{ .NetworkSettings.IPAddress }}' solr5`
on port 8983
