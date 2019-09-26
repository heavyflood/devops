FROM openjdk:8-jdk-alpine
MAINTAINER 'jiwan8985' 'jiwan8985@gmail.com'
VOLUME /tmp
ARG SERVER_ENV=dev
ENV SERVER_ENV ${SERVER_ENV}
ENV JAVA_OPTS="-XX:PermSize=1024m -XX:MaxPermSize=512m -Xmx4g -Xms2g"
COPY ./app.jar app.jar
ENTRYPOINT ["java", "-Dspring.profiles.active=${SERVER_ENV}", "-jar","/app.jar"]