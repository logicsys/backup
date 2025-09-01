#!/bin/bash

if [ "$#" -lt 1 ]; then
	echo "${0} <RUBY_VER>"
	exit 2
fi

CDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

RUBY_VER="3.3"

# create a temp podman container for a target ruby version
CONTAINER_ID=$(podman run -d -it -v "${CDIR}":/app --rm docker.io/library/ruby:${RUBY_VER})

if [ "$?" -ne 0 ]; then
	echo "error starting container"
	exit 1
fi

# 
podman exec -it "${CONTAINER_ID}" bash -l -c "ls -l /app"

# try build
podman exec -it "${CONTAINER_ID}" bash -l -c "apt-get update -y && apt-get install -y libxml2-dev"
podman exec -it "${CONTAINER_ID}" bash -l -c "cd /app && bundle install"
podman exec -it "${CONTAINER_ID}" bash -l -c "cd /app && rake --tasks"
podman exec -it "${CONTAINER_ID}" bash -l -c "cd /app && bundle outdated"
# podman exec -it "${CONTAINER_ID}" bash -l -c "cd /app && rake "
# podman exec -it "${CONTAINER_ID}" bash -l -c "cd /app && find / -name \"backup\" "
podman exec -it "${CONTAINER_ID}" bash -l -c "cd /app && gem build backup.gemspec"
podman exec -it "${CONTAINER_ID}" bash -l -c "cd /app && gem install backup-*.gem"
podman exec -it "${CONTAINER_ID}" bash -l -c "cd /app && find / -name \"backup\" "
podman exec -it "${CONTAINER_ID}" bash -l -c "/usr/local/bundle/bin/backup --help"
podman exec -it "${CONTAINER_ID}" bash -l -c "/usr/local/bundle/bin/backup version"
podman exec -it "${CONTAINER_ID}" bash -l -c "/usr/local/bundle/bin/backup generate:config"
podman exec -it "${CONTAINER_ID}" bash -l -c "/usr/local/bundle/bin/backup check"

podman stop "${CONTAINER_ID}"