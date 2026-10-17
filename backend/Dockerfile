# ==============================================================================
# Multi-stage Dockerfile for Peer Tutoring Board Backend (Spring Boot 3)
# ==============================================================================

# --- Stage 1: Build stage ---
FROM maven:3.9.9-eclipse-temurin-17-alpine AS builder
WORKDIR /app

# Copy dependency definition and source code
COPY pom.xml .
COPY src ./src

# Build production jar without tests (tests are run during CI/verify step)
RUN mvn clean package -DskipTests

# --- Stage 2: Minimal Runtime stage ---
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Create non-root system user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Copy executable jar from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose Spring Boot default port
EXPOSE 8080

# Run with UTC timezone configuration
ENTRYPOINT ["java", "-Duser.timezone=UTC", "-jar", "app.jar"]
