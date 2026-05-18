FROM maven:3.9.11-eclipse-temurin-25

LABEL maintainer="Stephan Krusche <krusche@tum.de>"

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends gnupg gradle \
    && rm -rf /var/lib/apt/lists/*

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
