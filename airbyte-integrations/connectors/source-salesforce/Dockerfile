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
    # Fix for PyYAML build bug related to Cython 3.0
    # https://github.com/yaml/pyyaml/issues/601
    pip install . --no-build-isolation

RUN pip uninstall setuptools -y && \
    pip uninstall pip -y

# silently breaking when running as non-root
# RUN addgroup -S appgroup && \
#     adduser -S appuser -G appgroup -u 1000
# USER appuser

ENV TZ UTC
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENTRYPOINT ["python", "/airbyte/integration_code/main.py"]

LABEL io.airbyte.version=2.0.12
LABEL io.airbyte.name=airbyte/source-salesforce
