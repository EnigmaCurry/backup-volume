set export

current_dir := `pwd`
IMAGE := "backup-volume-dev"
TEST_VOLUME := "backup-volume-dev"

# print help for Just targets
help:
    @just -l

# build Docker image
build:
    docker build -t ${IMAGE} .

# create test volume
create-test-volume volume_name:
	docker volume ls --format '{{"{{.Name}}"}}' | grep -q "^{{volume_name}}$" || \
	  (docker volume create {{volume_name}} && \
	  docker run --rm -v {{volume_name}}:/data alpine sh -c 'echo "Hello, World!" > /data/test.txt')

# run development loop
dev: build
    @just create-test-volume ${TEST_VOLUME}
    docker run --rm -it -v ${TEST_VOLUME}:/backup/test \
    -e BACKUP_LIFECYCLE_PHASE_ARCHIVE=false \
    -e BACKUP_CRON_EXPRESSION="@every 1m" \
    --entrypoint backup \
    ${IMAGE}
