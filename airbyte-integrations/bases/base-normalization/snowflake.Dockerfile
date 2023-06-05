FROM python:3.9-alpine3.18

RUN apk add --update --no-cache \
    build-base \
    openssl-dev \
    libffi-dev \
    zlib-dev \
    bzip2-dev \
    bash

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

RUN pip uninstall setuptools -y && \
    PATH=$ROOTPATH pip uninstall setuptools -y && \
    pip uninstall pip -y && \
    PATH=$ROOTPATH pip uninstall pip -y && \
    rm -rf /usr/local/lib/python3.10/ensurepip && \
    apk --purge del apk-tools py-pip && \
    # remove unnecessary private keys
    find /opt/ /usr/ -name '*.pem' | grep test | xargs rm
