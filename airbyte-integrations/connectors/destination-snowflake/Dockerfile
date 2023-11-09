FROM airbyte/integration-base-java:dev

# uncomment to run Yourkit java profiling
#RUN yum install -y curl zip
#
#RUN curl -o /tmp/YourKit-JavaProfiler-2021.3-docker.zip https://www.yourkit.com/download/docker/YourKit-JavaProfiler-2021.3-docker.zip && \
#  unzip /tmp/YourKit-JavaProfiler-2021.3-docker.zip -d /usr/local && \
#  rm /tmp/YourKit-JavaProfiler-2021.3-docker.zip

WORKDIR /airbyte

ENV APPLICATION destination-snowflake

# Needed for JDK17 (in turn, needed on M1 macs) - see https://github.com/snowflakedb/snowflake-jdbc/issues/589#issuecomment-983944767
#ENV DESTINATION_SNOWFLAKE_OPTS "--add-opens java.base/java.nio=ALL-UNNAMED"

COPY build/distributions/${APPLICATION}*.tar ${APPLICATION}.tar

RUN tar xf ${APPLICATION}.tar --strip-components=1

ENV ENABLE_SENTRY true

# silently breaking when running as non-root
# RUN addgroup -S appgroup && \
#     adduser -S appuser -G appgroup -u 1000
# USER appuser

LABEL io.airbyte.version=1.0.3
LABEL io.airbyte.name=airbyte/destination-snowflake

# Removes vulnerabilities flagged in Prisma

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2020-28052
RUN rm /airbyte/lib/bcprov-jdk15on-1.66.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2023-1370
RUN rm /airbyte/lib/nimbus-jose-jwt-9.8.1.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2023-34455
RUN rm /airbyte/lib/snappy-java-1.1.8.3.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2022-31197
RUN rm /airbyte/lib/postgresql-42.3.5.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2020-28052
RUN rm /airbyte/lib/bcpkix-jdk15on-1.66.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2023-1370
RUN rm /airbyte/lib/json-smart-2.4.10.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2022-41881
RUN rm /airbyte/lib/azure-core-http-netty-1.10.0.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2023-2976
RUN rm /airbyte/lib/hadoop-shaded-guava-1.1.1.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2022-42004
RUN rm /airbyte/lib/parquet-jackson-1.13.1.jar	
RUN rm /airbyte/lib/jackson-core-2.15.1.jar
RUN rm /airbyte/lib/netty-buffer-4.1.86.Final.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2023-34462
RUN rm /airbyte/lib/aws-java-sdk-bundle-1.12.316.jar
RUN rm /airbyte/lib/netty-handler-4.1.86.Final.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2022-41915
RUN rm /airbyte/lib/reactor-netty-http-1.0.7.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2023-34462
RUN rm /airbyte/lib/netty-codec-4.1.86.Final.jar

# CVE: https://nvd.nist.gov/vuln/detail/CVE-2022-41915
RUN rm /airbyte/lib/netty-codec-http-4.1.86.Final.jar
RUN rm /airbyte/lib/netty-codec-http2-4.1.86.Final.jar