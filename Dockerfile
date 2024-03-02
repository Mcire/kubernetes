FROM openjdk:17-jdk-slim

LABEL maintainer="che444 macdialloisidk@groupeisi.com"

EXPOSE 8080

ADD target/kubernetes-che.jar kubernetes-che.jar

ENTRYPOINT ["java", "-jar", "kubernetes-che.jar"]