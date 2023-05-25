FROM python:3.11.3-alpine3.18

# Bash is installed for more convenient debugging.
#RUN apt-get update && apt-get install -y bash && rm -rf /var/lib/apt/lists/*
RUN apk add py3-pandas

ENV AIRBYTE_ENTRYPOINT "python /airbyte/integration_code/main.py"

WORKDIR /airbyte/integration_code
COPY source_salesforce ./source_salesforce
COPY setup.py ./
COPY main.py ./
RUN pip install .

RUN pip uninstall setuptools -y && \
    pip uninstall pip -y

#RUN useradd appuser
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup -u 1000
USER appuser

ENTRYPOINT ["python", "/airbyte/integration_code/main.py"]

LABEL io.airbyte.version=2.0.12
LABEL io.airbyte.name=airbyte/source-salesforce
