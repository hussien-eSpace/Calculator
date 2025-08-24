# Build stage
FROM maven:3.8-openjdk-11 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean compile

# Run stage
FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=build /app/target/classes ./classes
COPY --from=build /app/target/dependency-jars ./lib
EXPOSE 8080
CMD ["java", "-cp", "classes:lib/*", "com.houarizegai.calculator.App"]