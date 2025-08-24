# Build stage
FROM maven:3.8-openjdk-11 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean compile

# Run stage
FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=build /app/target/classes ./
COPY --from=build /root/.m2/repository ./lib
EXPOSE 8080
CMD ["java", "-cp", ".:lib/*/*", "com.houarizegai.calculator.App"]