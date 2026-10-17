# Peer Tutoring Board — Backend (Spring Boot 3)

Backend REST API for Peer Tutoring Board built with Spring Boot 3, Java 17/21, Spring Security with stateless JWT, Spring Data JPA, and PostgreSQL.

---

## 1. Prerequisites

- **Java JDK**: Version 17 or higher (tested with JDK 21 Hotspot).
- **Maven**: Bundled Maven wrapper (`.mvn/wrapper/`) is included in the project.
- **Database**: PostgreSQL 16 (via Docker Compose or local installation).
- **PowerShell / Bash**: For running automated test and verification scripts.

---

## 2. How to Start with Docker Compose

A `docker-compose.yml` is provided at the workspace root to run both the PostgreSQL 16 database and the backend container together:

```bash
# 1. Ensure .env exists (copy from .env.example if needed)
cp .env.example .env

# 2. Build and run both services in background:
docker compose up --build -d
```

This launches:
- `peertutor-db`: PostgreSQL 16 on port `5432` with health checks and persistent volume `pgdata`.
- `peertutor-backend`: Multi-stage built Spring Boot container on port `8080`, automatically waiting for the database to be healthy.


This launches a PostgreSQL container (`peertutor-db`) on port `5432`:
- **Database Name**: `peertutor`
- **Username**: `postgres`
- **Password**: `postgres`
- **Port**: `5432`

Hibernate automatically creates and updates tables using `spring.jpa.hibernate.ddl-auto=update`. Initial reference data (the 10 core subjects) is seeded on first startup by `DataSeeder`.

---

## 3. Environment Variables

All sensitive credentials and environment-specific settings are configurable via environment variables with safe defaults for local development:

| Variable | Description | Default Value |
|---|---|---|
| `DB_URL` | JDBC URL for PostgreSQL | `jdbc:postgresql://localhost:5432/peertutor` |
| `DB_USER` | PostgreSQL username | `postgres` |
| `DB_PASS` | PostgreSQL password | `postgres` |
| `JWT_SECRET` | HMAC-SHA secret for signing JWTs (32+ chars) | `change-this-to-a-long-random-secret-at-least-32-chars!!` |
| `CORS_ORIGINS` | Allowed origins for CORS | `http://localhost:3000` |

---

## 4. How to Run the Backend

### Windows (PowerShell / Command Prompt)

Using the bundled Maven wrapper:

```powershell
# Set JAVA_HOME (if not already in PATH)
$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-21.0.10.7-hotspot"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

# Run Spring Boot server
$jar = ".mvn\wrapper\maven-wrapper.jar"
java -classpath $jar "-Dmaven.multiModuleProjectDirectory=$PWD" org.apache.maven.wrapper.MavenWrapperMain spring-boot:run
```

Or with global Maven:
```powershell
mvn spring-boot:run
```

The application starts on `http://localhost:8080`.

---

## 5. How to Run the Tests

To execute the unit and integration test suite (including `ChatServiceTest` with fixed `Clock` boundary conditions):

### Windows (PowerShell)
```powershell
$jar = ".mvn\wrapper\maven-wrapper.jar"
java -classpath $jar "-Dmaven.multiModuleProjectDirectory=$PWD" org.apache.maven.wrapper.MavenWrapperMain test
```

### Linux / macOS
```bash
./mvnw test
```

---

## 6. API Documentation (Swagger / OpenAPI)

Once the backend is running, the interactive OpenAPI documentation is available at:

- **Swagger UI**: [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)
- **OpenAPI JSON**: [http://localhost:8080/v3/api-docs](http://localhost:8080/v3/api-docs)
- **Health Check**: [http://localhost:8080/api/health](http://localhost:8080/api/health)

---

## 7. How to Run the End-to-End (E2E) Verification Script

An automated script tests the full flow (registering unique accounts, creating profile, posting availability slot, searching tutors, requesting slot, accepting request, and verifying chat state):

### Windows (PowerShell)
```powershell
powershell -ExecutionPolicy Bypass -File scripts/e2e.ps1
```

### Linux / macOS (Bash)
```bash
chmod +x scripts/e2e.sh
./scripts/e2e.sh
```

---

## 8. Summary of API Endpoints (Architecture.md Section 6)

| # | Method | Path | Role | Description |
|---|---|---|---|---|
| 1 | `POST` | `/api/auth/register` | Public | Register student or tutor |
| 2 | `POST` | `/api/auth/login` | Public | Login with email & password |
| 3 | `GET` | `/api/auth/me` | Authenticated | Get current user info & `hasTutorProfile` |
| 4 | `GET` | `/api/subjects` | Authenticated | List all subjects |
| 5 | `GET` | `/api/tutors` | Authenticated | Search & filter tutors with open future slots |
| 6 | `GET` | `/api/tutors/{id}` | Authenticated | Get tutor profile by profile ID |
| 7 | `GET` | `/api/tutors/{id}/slots` | Authenticated | Get open future unbooked slots for tutor |
| 8 | `GET` | `/api/tutors/me` | TUTOR | Get own tutor profile (404 if none) |
| 9 | `PUT` | `/api/tutors/me` | TUTOR | Create or update tutor profile |
| 10 | `POST` | `/api/slots` | TUTOR | Post a new availability slot |
| 11 | `GET` | `/api/slots/mine` | TUTOR | Get all tutor's active slots with `requestCount` |
| 12 | `DELETE`| `/api/slots/{id}` | TUTOR (owner) | Delete an unbooked availability slot |
| 13 | `POST` | `/api/requests` | STUDENT | Send session request for a slot |
| 14 | `GET` | `/api/requests/outgoing` | STUDENT | List student's requests (optional `?status=`) |
| 15 | `PATCH`| `/api/requests/{id}/cancel` | STUDENT (owner) | Cancel pending session request |
| 16 | `GET` | `/api/requests/incoming` | TUTOR | List incoming requests (optional `?status=`) |
| 17 | `PATCH`| `/api/requests/{id}/status` | TUTOR (owner) | Accept or decline request (auto-declines others) |
| 18 | `GET` | `/api/chats` | Authenticated | List user's accepted sessions with chat state |
| 19 | `GET` | `/api/requests/{id}/messages` | Participant | Poll messages for accepted request (`?afterId=`) |
| 20 | `POST` | `/api/requests/{id}/messages` | Participant | Send post-session message when `OPEN` |
| 21 | `POST` | `/api/subjects` | TUTOR | Add a new subject (201 if new, 200 if exists) |
