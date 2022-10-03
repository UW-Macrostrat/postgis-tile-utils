test:
	docker run -d --name postgis_tile_test --rm \
		--env POSTGRES_HOST_AUTH_METHOD=trust \
		--env POSTGRES_DB=postgres \
		--volume $(shell pwd)/sql:/sql:ro \
		--volume $(shell pwd)/test.sh:/test/test.sh:ro \
		postgis/postgis:14-3.3 \
				-c shared_buffers=500MB \
    		-c fsync=off
	docker exec -it postgis_tile_test /test/test.sh
	docker stop postgis_tile_test
