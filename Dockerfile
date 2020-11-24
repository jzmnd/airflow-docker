# AIRFLOW VERSION 1.10.12
# PYTHON VERSION 3.6
# Customized version of the puckel/docker-airflow image

FROM python:3.6-slim
LABEL maintainer="Jeremy Smith <j.smith.03@cantab.net>"

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_VERSION=1.10.12
ARG AIRFLOW_EXTRAS="crypto,celery,postgres,redis,hive,jdbc,mssql,mysql,kubernetes,s3,ssh,statsd,virtualenv,vertica"
ARG AIRFLOW_USER_HOME=/usr/local/airflow
ARG AIRFLOW_USER=airflow
ENV AIRFLOW_HOME=${AIRFLOW_USER_HOME}

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

RUN set -ex \
    && buildDeps=" \
        freetds-dev \
        libkrb5-dev \
        libldap2-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        libpq-dev \
    " \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        freetds-bin \
        build-essential \
        default-libmysqlclient-dev \
        apt-utils \
        curl \
        rsync \
        netcat \
        locales \
        git \
    && sed -i "s/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g" /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${AIRFLOW_USER_HOME} ${AIRFLOW_USER} \
    && pip install -U pip setuptools wheel \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install python-ldap \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install apache-airflow[${AIRFLOW_EXTRAS}]==${AIRFLOW_VERSION} \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base \
        /root/.cache/pip

COPY scripts/entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_USER_HOME}/airflow.cfg

RUN chown -R airflow: ${AIRFLOW_USER_HOME}
RUN chgrp -R 0 ${AIRFLOW_USER_HOME} && chmod -R g+rwX ${AIRFLOW_USER_HOME}

EXPOSE 8080 5555 8793

USER ${AIRFLOW_USER}
WORKDIR ${AIRFLOW_USER_HOME}

COPY requirements.txt /tmp/requirements.txt
RUN pip install --user -r /tmp/requirements.txt

ENTRYPOINT ["/entrypoint.sh"]
CMD ["webserver"]
