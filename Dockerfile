FROM openjdk:17-jdk-slim

LABEL maintainer="che444 macdialloisidk@groupeisi.com"

EXPOSE 8080

ADD target/kubernetes.jar kubernetes.jar

ENTRYPOINT ["java", "-jar", "kubernetes.jar"]