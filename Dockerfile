# Build stage
FROM maven:3.8-openjdk-11 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package
RUN mvn dependency:copy-dependencies -DoutputDirectory=target/lib

# Run stage
FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=build /app/target/Calculator-1.0-SNAPSHOT.jar ./app.jar
COPY --from=build /app/target/lib ./lib
EXPOSE 8080
# Fix the GUI issue by running in headless mode
CMD ["java", "-Djava.awt.headless=true", "-cp", "app.jar:lib/*", "com.houarizegai.calculator.App"]