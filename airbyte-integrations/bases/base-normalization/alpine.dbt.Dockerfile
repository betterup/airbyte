FROM alpine:3.18 as base

ENV LANG=C.UTF-8

RUN apk update &&\
    apk upgrade &&\
    apk add --no-cache build-base openssl-dev libffi-dev zlib-dev bzip2-dev dpkg

ENV PYTHON_MINOR=11
ENV PYTHON_PATCH=3
ENV PYTHON_VERSION=3.${PYTHON_MINOR}.${PYTHON_PATCH}
ENV PYTHON_SHA256=1a79f3df32265d9e6625f1a0b31c28eb1594df911403d11f3320ee1da1b3e048

FROM base as python-src
ENV PYTHON_URL=https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
# injects space for proper checksum in alpine/busybox
# https://github.com/alpinelinux/docker-alpine/issues/246
COPY entrypoint.sh /usr/bin/
COPY script-download.sh /usr/bin/
RUN chmod 755 /usr/bin/download-src
RUN download-src $PYTHON_URL "$PYTHON_SHA256 "

FROM base as python-base

COPY --from=python-src /downloads/ /usr/src/

# forces extra space for proper checksum
# https://github.com/alpinelinux/docker-alpine/issues/246
RUN \
# install python w/out fips
cd /usr/src/Python-${PYTHON_VERSION} && \
./configure --with-ensure-pip --enable-optimizations && \
make && \
make install && \
make clean && \
update-alternatives \
    --install /usr/bin/python python /usr/local/bin/python3.${PYTHON_MINOR} 10 \
    --force && \
update-alternatives \
    --install /usr/bin/pip pip /usr/local/bin/pip3.${PYTHON_MINOR} 10 --force

RUN pip install dbt