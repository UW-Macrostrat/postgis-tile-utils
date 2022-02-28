test:
	docker build -t postgis_tile_utils_tests -f Dockerfile.testing .
	docker run --rm postgis_tile_utils_tests /tests/test.sh