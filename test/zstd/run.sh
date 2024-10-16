#!/bin/sh

set -e

cd $(dirname $0)
. ../util.sh
current_test=$(basename $(pwd))

docker network create test_network
docker volume create app_data

LOCAL_DIR=$(mktemp -d)

docker run -d -q \
  --name enigmacurry \
  --network test_network \
  -v app_data:/var/opt/enigmacurry/ \
  enigmacurry/enigmacurry:latest

sleep 10

docker run --rm -q \
  --network test_network \
  -v app_data:/backup/app_data \
  -v $LOCAL_DIR:/archive \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --env BACKUP_COMPRESSION=zst \
  --env BACKUP_FILENAME='test.{{ .Extension }}' \
  --entrypoint backup \
  enigmacurry/backup-volume:${TEST_VERSION:-canary}

tmp_dir=$(mktemp -d)
tar -xvf "$LOCAL_DIR/test.tar.zst" --zstd -C $tmp_dir
if [ ! -f "$tmp_dir/backup/app_data/enigmacurry.db" ]; then
  fail "Could not find expected file in untared archive."
fi
pass "Found relevant files in untared local backup."

# This test does not stop containers during backup. This is happening on
# purpose in order to cover this setup as well.
expect_running_containers "1"
