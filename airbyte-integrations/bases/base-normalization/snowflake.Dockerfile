FROM alpine:3.18 as base

ENV LANG=C.UTF-8

RUN apk update &&\
    apk upgrade &&\
    apk add --no-cache build-base openssl-dev libffi-dev zlib-dev bzip2-dev dpkg jq sshpass

# compiles python

ENV PYTHON_MINOR=11
ENV PYTHON_PATCH=3
ENV PYTHON_VERSION=3.${PYTHON_MINOR}.${PYTHON_PATCH}
ENV PYTHON_SHA256=1a79f3df32265d9e6625f1a0b31c28eb1594df911403d11f3320ee1da1b3e048

FROM base as python-src
ENV PYTHON_URL=https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
COPY entrypoint.sh /usr/bin/
COPY download-src /usr/bin/
RUN chmod 755 /usr/bin/download-src
RUN download-src $PYTHON_URL "$PYTHON_SHA256 "

FROM base as python-base

COPY --from=python-src /downloads/ /usr/src/

RUN cd /usr/src/Python-${PYTHON_VERSION} && \
    ./configure --with-ensure-pip --enable-optimizations && \
    make && \
    make install && \
    make clean && \
    update-alternatives \
        --install /usr/bin/python python /usr/local/bin/python3.${PYTHON_MINOR} 10 \
        --force && \
    update-alternatives \
        --install /usr/bin/pip pip /usr/local/bin/pip3.${PYTHON_MINOR} 10 --force

ENV ROOTPATH="/usr/local/bin:$PATH"
ENV REQUIREPATH="/opt/.venv/bin:$PATH"

RUN PATH=$ROOTPATH python -m venv /opt/.venv

ENV PATH=$REQUIREPATH

RUN pip install --upgrade pip && \
    pip install dbt-core

COPY --from=airbyte/base-airbyte-protocol-python:0.1.1 /airbyte /airbyte

# Install SSH Tunneling dependencies
RUN apk add --update jq sshpass

WORKDIR /airbyte
COPY entrypoint.sh .
COPY build/sshtunneling.sh .

WORKDIR /airbyte/normalization_code
COPY normalization ./normalization
COPY setup.py .
COPY dbt-project-template/ ./dbt-template/
COPY dbt-project-template-snowflake/* ./dbt-template/

# Install python dependencies
WORKDIR /airbyte/base_python_structs
RUN pip install .

WORKDIR /airbyte/normalization_code
RUN pip install .

WORKDIR /airbyte/normalization_code/dbt-template/
# Download external dbt dependencies
RUN apk add git && touch profiles.yml && dbt deps --profiles-dir . && apk del git

WORKDIR /airbyte
ENV AIRBYTE_ENTRYPOINT "/airbyte/entrypoint.sh"
ENTRYPOINT ["/airbyte/entrypoint.sh"]

LABEL io.airbyte.version=0.2.5
LABEL io.airbyte.name=airbyte/normalization-snowflake

# patch for https://nvd.nist.gov/vuln/detail/CVE-2023-30608
RUN pip install sqlparse==0.4.4

RUN adduser -s /bin/sh -u 1000 -D dbt_user

RUN pip uninstall setuptools -y && \
    PATH=$ROOTPATH pip uninstall setuptools -y && \
    pip uninstall pip -y && \
    PATH=$ROOTPATH pip uninstall pip -y && \
    rm -rf /usr/local/lib/python3.10/ensurepip && \
    apk --purge del apk-tools py-pip && \
    # remove unnecessary private keys
    find /opt/ /usr/ -name '*.pem' | grep test | xargs rm

USER dbt_user
