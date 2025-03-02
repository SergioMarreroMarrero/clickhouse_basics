CONTAINER_NAME=clickhouse
LOCAL_VOLUME_PATH=C:\Users\oigre\Documents\repos\clickhouse_basics\data
IMAGE_VOLUME_PATH=/var/lib/clickhouse/user_files/data
IMAGE_NAME=clickhouse/clickhouse-server:latest

run:
	docker run -d -p 8123:8123 -p 9000:9000 \
	  -e CLICKHOUSE_PASSWORD=clickhouse \
	  --name $(CONTAINER_NAME) \
	  -v $(LOCAL_VOLUME_PATH):$(IMAGE_VOLUME_PATH) \
	  $(IMAGE_NAME)

stop:
	docker stop $(CONTAINER_NAME)

restart:
	docker restart $(CONTAINER_NAME)

remove:
	docker rm -f $(CONTAINER_NAME)

list_files:
	docker exec -it $(CONTAINER_NAME) ls $(IMAGE_VOLUME_PATH)
