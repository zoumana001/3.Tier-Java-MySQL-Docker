FROM eclipse-temurin:17-jdk-alpine AS build

WORKDIR /app

# Copy mvnw and pom.xml first
COPY mvnw pom.xml ./

# Create .mvn directory if it doesn't exist and download wrapper
RUN mkdir -p .mvn/wrapper && \
    if [ ! -f .mvn/wrapper/maven-wrapper.properties ]; then \
        echo "Creating missing maven-wrapper.properties..." && \
        echo "distributionUrl=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.8.6/apache-maven-3.8.6-bin.zip" > .mvn/wrapper/maven-wrapper.properties && \
        echo "wrapperUrl=https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.1.0/maven-wrapper-3.1.0.jar" >> .mvn/wrapper/maven-wrapper.properties; \
    fi && \
    if [ ! -f .mvn/wrapper/maven-wrapper.jar ]; then \
        echo "Downloading maven-wrapper.jar..." && \
        wget -q -O .mvn/wrapper/maven-wrapper.jar https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.1.0/maven-wrapper-3.1.0.jar; \
    fi

# Make mvnw executable
RUN chmod +x mvnw

# Verify mvnw works
RUN ./mvnw --version

# Download dependencies (offline mode)
RUN ./mvnw dependency:go-offline -B

# Copy source code
COPY src src

# Build the application
RUN ./mvnw clean package -DskipTests

# Run stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
