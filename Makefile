N_WORKERS := 5

build:
	@docker-compose build

start:
	@docker-compose up -d --scale worker=$(N_WORKERS)

stop:
	@docker-compose down

.PHONY: build start stop
