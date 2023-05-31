FROM alpine:3.18 as base

ENV LANG=C.UTF-8

RUN apk update &&\
    apk upgrade &&\
    apk add --no-cache build-base openssl-dev libffi-dev zlib-dev bzip2-dev dpkg jq sshpass

# compiles python

ENV PYTHON_MINOR=11
ENV PYTHON_PATCH=3
ENV PYTHON_VERSION=3.${PYTHON_MINOR}.${PYTHON_PATCH}

FROM base as python-src
ENV PYTHON_URL=https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
RUN wget $PYTHON_URL && \
    FILENAME=$(basename $PYTHON_URL) && \
    tar -xzvf $FILENAME
    rm $FILENAME


FROM base as python-base

COPY --from=python-src /downloads/ /usr/src/

# forces extra space for proper checksum
# https://github.com/alpinelinux/docker-alpine/issues/246
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

ENV AIRBYTE_ENTRYPOINT "python /airbyte/integration_code/main.py"

WORKDIR /airbyte/integration_code
COPY source_salesforce ./source_salesforce
COPY setup.py ./
COPY main.py ./
RUN pip install .

RUN pip uninstall setuptools -y && \
    pip uninstall pip -y

RUN useradd appuser
USER appuser

ENTRYPOINT ["python", "/airbyte/integration_code/main.py"]

LABEL io.airbyte.version=2.0.12
LABEL io.airbyte.name=airbyte/source-salesforce
