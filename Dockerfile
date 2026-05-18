FROM maven:3.9.11-eclipse-temurin-25

LABEL maintainer="Stephan Krusche <krusche@tum.de>"

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends gnupg && \
    rm -rf /var/lib/apt/lists/*


    # 1. Install prerequisites, download Gradle, extract, and clean up in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        default-jdk \
        wget \
        unzip \
        ca-certificates && \
    wget -q https://services.gradle.org/distributions/gradle-9.0.0-bin.zip -P /tmp && \
    mkdir -p /opt/gradle && \
    unzip -q -d /opt/gradle /tmp/gradle-9.0.0-bin.zip && \
    rm -f /tmp/gradle-9.0.0-bin.zip && \
    apt-get remove -y wget unzip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 2. Set the environment variables so Gradle is available on the PATH
ENV GRADLE_HOME=/opt/gradle/gradle-9.0.0
ENV PATH=${GRADLE_HOME}/bin:${PATH}

ENV M2_HOME=/usr/share/maven

RUN echo "$LANG -- $LANGUAGE -- $LC_ALL" \
    && curl --version \
    && gpg --version \
    && git --version \
    && mvn --version \
    && java --version \
    && javac --version

ADD artemis-java-template /opt/artemis-java-template

RUN cd /opt/artemis-java-template && pwd && ls -la && mvn clean install test && mvn spotbugs:spotbugs checkstyle:checkstyle pmd:pmd

RUN cd /opt/artemis-java-template && pwd && ls -la && gradle clean test check -x test publishToMavenLocal && gradle --version && gradle --stop

RUN rm -rf /opt/artemis-java-template

CMD ["mvn"]
