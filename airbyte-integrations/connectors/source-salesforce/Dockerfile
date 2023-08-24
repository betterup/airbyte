FROM python:3.9-alpine3.18

ENV ROOTPATH="/usr/local/bin:$PATH"
ENV REQUIREPATH="/opt/.venv/bin:$PATH"

RUN apk add --update --no-cache \
    build-base \
    openssl-dev \
    libffi-dev \
    zlib-dev \
    bzip2-dev

RUN PATH=$ROOTPATH python -m venv /opt/.venv

ENV PATH=$REQUIREPATH

ENV AIRBYTE_ENTRYPOINT "python /airbyte/integration_code/main.py"

WORKDIR /airbyte/integration_code
COPY source_salesforce ./source_salesforce
COPY setup.py ./
COPY main.py ./

RUN pip install --upgrade pip setuptools wheel && \
    # workaround for https://github.com/yaml/pyyaml/issues/601
    # this should be fixed in the airbyte/base-airbyte-protocol-python image
    pip install "Cython<3.0" "pyyaml==5.4" --no-build-isolation && \
    pip install numpy && \
    pip install .

RUN pip uninstall setuptools -y && \
    pip uninstall pip -y

# silently breaking when running as non-root
# RUN addgroup -S appgroup && \
#     adduser -S appuser -G appgroup -u 1000
# USER appuser

ENV TZ UTC
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# cleanup pip/setuptools in both environments
RUN pip uninstall setuptools -y &&\
    PATH=$ROOTPATH pip uninstall setuptools -y &&\
    pip uninstall pip -y &&\
    PATH=$ROOTPATH pip uninstall pip -y &&\
    rm -rf /usr/local/lib/python3.10/ensurepip &&\
    apk --purge del apk-tools py-pip

ENTRYPOINT ["python", "/airbyte/integration_code/main.py"]

LABEL io.airbyte.version=2.0.12
LABEL io.airbyte.name=airbyte/source-salesforce
