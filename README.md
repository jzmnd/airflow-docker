# airflow-docker

Customized version of the puckel/docker-airflow image. Running python 3.6 and airflow 1.10.12.

Docker compose using CeleryExecutor.

Includes requirements for common data science projects.

## Usage

- Set the environment variables `POSTGRES_PASSWORD`, `REDIS_PASSWORD`, `FERNET_KEY`, `ADMIN_USER`, `ADMIN_PASSWORD`
- Run `make start` to run services and `make stop` to shutdown
