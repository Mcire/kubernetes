# Kubernetes (k8s)
This project is a Spring Boot application with a REST endpoint that congratulates the user on successful deployment on Kubernetes. 
It uses Docker for packaging, MySQL as a database, and YAML files to deploy services on Kubernetes.

# Minikube instalation
To work with minikube, we need :
- install Chocolatey, a package manager for Windows, via PowerShell. 
```chocolatey
Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```
then
```chocolatey
choco install minikube
```
# Deploying the spring boot project: kubectl
We start by configuring the Docker environment to interact with the Docker daemon run by Minikube. 
It displays the environment variables we need to configure in our shell so that our local Docker instance can communicate with the Docker daemon managed by Minikube.
```minikube
minikube docker-env
```
## Dockerfile
```java
FROM openjdk:17-jdk-slim

LABEL maintainer="che444 macdialloisidk@groupeisi.com"

EXPOSE 8080

ADD target/kubernetes-che.jar kubernetes-che.jar

ENTRYPOINT ["java", "-jar", "kubernetes-che.jar"]
```
ce Dockerfile construit une image Docker contenant l'application Spring Boot et configure le conteneur pour exécuter cette application au démarrage.

## application.yml
```yml
spring:
  application:
    name: kubernetes-che
  datasource:
    url: jdbc:mysql://mysql:3306/k8s-db?createDatabaseIfNotExist=true
    username: 'root'
    password: 'che'
    driver-class-name: com.mysql.cj.jdbc.Driver
  jpa:
    database-platform: org.hibernate.dialect.MySQL8Dialect
    hibernate:
      ddl-auto: update
    show-sql: true

server:
  port: 8080
```
This file configures various aspects of the Spring Boot application, including database connection, JPA entity management and the port on which the application will be exposed.

## deployment.yml
```yml
  apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql-k8s
          image: mysql:8.0.23
          ports:
            - containerPort: 3306
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: che
            - name: MYSQL_DATABASE
              value: k8s-db

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: kubernetes-che
spec:
  selector:
    matchLabels:
      app: kubernetes-che
  replicas: 2
  template:
    metadata:
      labels:
        app: kubernetes-che
    spec:
      containers:
        - name: kubernetes-che
          image: che444/kubernetes-che:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080

```
This file is used to define how applications will be deployed and run on Kubernetes, specifying the details of each container and their deployment. It enables :
- Define deployments for two applications: the Spring Boot application and the MySQL database.
- Specify the number of replicas for each deployment.
- Configure containers with the appropriate Docker images.
- Define the ports on which containers will be exposed.

## service.yml
```yml
  apiVersion: v1
  kind: Service
  metadata:
    name: kubernetes-che
  spec:
    selector:
      app: kubernetes-che
    ports:
      - protocol: TCP
        port: 8080
        targetPort: 8080
  ---
  apiVersion: v1
  kind: Service
  metadata:
    name: mysql
  spec:
    selector:
      app: mysql
    ports:
      - protocol: TCP
        port: 3306
```
This file configures network communication rules to allow access to applications deployed on Kubernetes from other services or from outside the cluster. To do this, it :
- Defines two Kubernetes services, one for the Spring Boot application and one for the MySQL database.
- Maps container ports to the ports exposed by the services.
- Allows other Kubernetes services to access applications via these services.

## configuration
- build docker image 
``` docker
docker build -t kubernetes-che . 
```
- Pushing the image into docker hub
```docker
docker tag kubernetes-che:latest che444/kubernetes-che:latest
docker push che444/kubernetes-che:latest 
```
- deploying the project in the kubernetes cluster
```kubectl
kubectl create deployment kubernetes-che --image=che444/kubernetes-che:latest  --port=8080
```
or
```Kubectl
kubectl apply -f deployment.yml
```
- To check:
```kubectl
kubectl get deployment
```
![Screenshot 2024-03-02 003534](https://github.com/Mcire/kubernetes/assets/95756307/5d67dceb-dddc-4e4f-ada4-4fed536bd040)

- For deployment details:
```kubectl
kubectl describe deployment kubernetes-che
```
- create the service
```kubectl
kubectl apply -f service.yml
```
- To check
```kubectl
kubectl get service
```
![Screenshot 2024-03-02 003506](https://github.com/Mcire/kubernetes/assets/95756307/f995dcbf-a955-4741-9fa9-74f1a3ee3f91)

# Result
### Test
- view our endpoint through this link: http://127.0.0.1:52536/message
![Screenshot 2024-03-02 003839](https://github.com/Mcire/kubernetes/assets/95756307/3068376f-7e78-426c-a5b8-d139c30aa44c)

- launch the monitoring dashboard
```kubectl
minikube dashboard
```

*workloads*<br>
![Screenshot 2024-02-28 224009](https://github.com/Mcire/kubernetes/assets/95756307/67d163d5-eae9-46ac-89f4-bfb00a43b04f)
*jobs*<br>
![Screenshot 2024-03-02 003442](https://github.com/Mcire/kubernetes/assets/95756307/b12f80f3-f579-4cfe-9def-d7ffe7951988)
NB: if one pod falls another will be automatically created by kibernates <br><br>
![Screenshot 2024-03-02 003713](https://github.com/Mcire/kubernetes/assets/95756307/52ebac48-5eb8-4cb0-8c8e-646182997696)
*Pods*<br>
![Screenshot 2024-03-02 004443](https://github.com/Mcire/kubernetes/assets/95756307/699bc218-2236-48d5-8f57-126dfff42f6b)
*Replica sets*<br>
![Screenshot 2024-03-02 004506](https://github.com/Mcire/kubernetes/assets/95756307/23d89863-7bc3-4fa6-838e-666d0769a647)



