# Build stage
FROM maven:3.8-openjdk-11 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
# Build and copy dependencies
RUN mvn clean package
RUN mvn dependency:copy-dependencies -DoutputDirectory=target/lib

# Run stage
FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=build /app/target/Calculator-1.0-SNAPSHOT.jar ./app.jar
COPY --from=build /app/target/lib ./lib
EXPOSE 8080
CMD ["java", "-cp", "app.jar:lib/*", "com.houarizegai.calculator.App"]