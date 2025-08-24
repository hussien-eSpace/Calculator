# Use OpenJDK 11 as base image
FROM openjdk:11-jdk

# Set working directory
WORKDIR /app

# Install Maven and X11 libraries for Swing GUI
RUN apt-get update && apt-get install -y maven \
    libxext6 \
    libxrender1 \
    libxtst6 \
    libxi6 \
    libxrandr2 \
    libxss1 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxfixes3 \
    libxinerama1 \
    libxtst6 \
    libnss3 \
    libcups2 \
    libdrm2 \
    libgtk-3-0 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Copy Maven pom.xml first for better caching
COPY pom.xml .

# Download dependencies (this layer will be cached if pom.xml doesn't change)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src/ ./src/

# Build the application and copy dependencies
RUN mvn clean package -DskipTests
RUN mvn dependency:copy-dependencies -DoutputDirectory=target/lib

# Create a script to run the Swing application
RUN echo '#!/bin/bash\necho "Starting Calculator Application..."\njava -cp "target/Calculator-1.0-SNAPSHOT.jar:target/lib/*" com.houarizegai.calculator.App' > run.sh && \
    chmod +x run.sh

# Expose display for X11 forwarding
ENV DISPLAY=:0

# Set the entrypoint
ENTRYPOINT ["./run.sh"]