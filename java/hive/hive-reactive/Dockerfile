# Build stage
FROM maven:3.9-eclipse-temurin-25 AS builder

WORKDIR /app

# Copy parent pom and module pom
COPY pom.xml /app/parent-pom.xml
COPY hive-reactive/pom.xml /app/pom.xml

# Copy source
COPY hive-reactive/src /app/src

# Build the application (skip tests for faster builds)
RUN --mount=type=cache,target=/root/.m2 \
    mvn -f /app/parent-pom.xml install -N -q && \
    mvn package -DskipTests -q

# Runtime stage (using JDK for JFR/jcmd support)
FROM eclipse-temurin:25-jdk

WORKDIR /app

# Copy the built jar
COPY --from=builder /app/target/*.jar app.jar

# JVM options for reactive application
ENV JAVA_OPTS="-XX:+UseG1GC -XX:MaxGCPauseMillis=100 -XX:+UseStringDeduplication"

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
