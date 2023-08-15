FROM python:3.11-alpine3.18

RUN apk add --update --no-cache \
    build-base \
    openssl-dev \
    libffi-dev \
    zlib-dev \
    bzip2-dev

ENV ROOTPATH="/usr/local/bin:$PATH"
ENV REQUIREPATH="/opt/.venv/bin:$PATH"

RUN PATH=$ROOTPATH python -m venv /opt/.venv

ENV PATH=$REQUIREPATH

RUN pip install --upgrade pip wheel && \
    # Fix for PyYAML build bug related to Cython 3.0
    # https://github.com/yaml/pyyaml/issues/601
    pip install dbt-core --no-build-isolation

# installs airbyte dependencies
COPY --from=airbyte/base-airbyte-protocol-python:0.1.1 /airbyte /airbyte

WORKDIR /airbyte
COPY entrypoint.sh .
COPY build/sshtunneling.sh .

WORKDIR /airbyte/normalization_code
COPY normalization ./normalization
COPY setup.py .
COPY dbt-project-template/ ./dbt-template/

# Install python dependencies
WORKDIR /airbyte/base_python_structs

# workaround for https://github.com/yaml/pyyaml/issues/601
# this should be fixed in the airbyte/base-airbyte-protocol-python image
RUN pip install "Cython<3.0" "pyyaml==5.4" --no-build-isolation

RUN pip install .

WORKDIR /airbyte/normalization_code
RUN pip install .

WORKDIR /airbyte/normalization_code/dbt-template/
# Download external dbt dependencies
RUN apk add git && touch profiles.yml && dbt deps --profiles-dir . && apk del git

WORKDIR /airbyte
ENV AIRBYTE_ENTRYPOINT "/airbyte/entrypoint.sh"
ENTRYPOINT ["/airbyte/entrypoint.sh"]

LABEL io.airbyte.version=0.4.3
LABEL io.airbyte.name=airbyte/normalization

RUN adduser -s /bin/sh -u 1000 -D dbt_user

# patch for https://nvd.nist.gov/vuln/detail/CVE-2023-30608
RUN pip install sqlparse==0.4.4

RUN pip uninstall setuptools -y && \
    PATH=$ROOTPATH pip uninstall setuptools -y && \
    pip uninstall pip -y && \
    PATH=$ROOTPATH pip uninstall pip -y && \
    rm -rf /usr/local/lib/python3.10/ensurepip && \
    apk --purge del apk-tools py-pip

USER dbt_user
