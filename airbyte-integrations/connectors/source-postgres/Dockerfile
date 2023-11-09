FROM airbyte/integration-base-java:dev AS build

WORKDIR /airbyte

ENV APPLICATION source-postgres

COPY build/distributions/${APPLICATION}*.tar ${APPLICATION}.tar

RUN tar xf ${APPLICATION}.tar --strip-components=1 && rm -rf ${APPLICATION}.tar

FROM airbyte/integration-base-java:dev

RUN apk add --update bash

WORKDIR /airbyte

ENV APPLICATION source-postgres

COPY --from=build /airbyte /airbyte
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup -u 1000

# needs root to create pipes
# USER appuser

LABEL io.airbyte.version=2.0.28
LABEL io.airbyte.name=airbyte/source-postgres

# Removes vulnerabilities flagged in Prisma

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2023-34455
# CVE: https://nvd.nist.gov/vuln/detail/CVE-2023-34454
# CVE: https://nvd.nist.gov/vuln/detail/CVE-2023-34453
RUN rm /airbyte/lib/snappy-java-1.1.8.4.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2023-2976
# CVE: https://nvd.nist.gov/vuln/detail/CVE-2020-8908
RUN rm /airbyte/lib/auto-value-1.10.1.jar
RUN rm /airbyte/lib/guava-32.1.2-jre.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2023-34462
RUN rm /airbyte/lib/netty-codec-4.1.92.Final.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2023-34462
RUN rm /airbyte/lib/netty-handler-4.1.92.Final.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2023-44487
RUN rm /airbyte/lib/netty-codec-http2-4.1.86.Final.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2023-44487
RUN rm /airbyte/lib/netty-codec-http2-4.1.86.Final.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2023-36478
RUN rm /airbyte/lib/jetty-io-11.0.15.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2023-31418
RUN rm /airbyte/lib/elasticsearch-7.17.6.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2023-31419
RUN rm /airbyte/lib/elasticsearch-7.17.6.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2023-31417
RUN rm /airbyte/lib/elasticsearch-7.17.6.jar

