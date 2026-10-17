# Railway Deployment Guide — Peer Tutoring Board Backend

This guide outlines the exact, step-by-step instructions to deploy the Spring Boot backend on Railway with an internal PostgreSQL database.

---

## 1. Prerequisites
- A [Railway](https://railway.app) account.
- Your project pushed to a GitHub repository.

---

## 2. Step-by-Step Deployment

### Step 2.1: Create Project & Database
1. Go to the [Railway Dashboard](https://railway.app/dashboard) and click **New Project**.
2. Select **Provision PostgreSQL**.
   - Note the service name created (by default it is named `Postgres` or `PostgreSQL`; if it defaults to `PostgreSQL`, you can rename the service to `Postgres` or match the reference variable prefix accordingly). In this guide, we assume the database service is named **`Postgres`**.

### Step 2.2: Add the Backend Service
1. In the same project canvas, click **Create** / **New Service** -> **GitHub Repo**.
2. Select your repository.
3. Click on the newly created backend service, open **Settings**:
   - Under **General** -> **Root Directory**, set it to:
     ```
     backend
     ```
     *(Railway will build from `backend/Dockerfile`)*
   - Under **Deploy** -> **Healthcheck Path**, set it to:
     ```
     /api/health
     ```

### Step 2.3: Configure Backend Environment Variables
1. Click on the backend service and navigate to the **Variables** tab.
2. Add the following variables using **Railway Reference Variables** (referencing the `Postgres` service):

| Variable Name | Value | Description |
| :--- | :--- | :--- |
| `DB_URL` | `jdbc:postgresql://${{Postgres.RAILWAY_PRIVATE_DOMAIN}}:${{Postgres.PGPORT}}/${{Postgres.PGDATABASE}}` | Internal JDBC URL constructed from private domain and port |
| `DB_USER` | `${{Postgres.PGUSER}}` | Railway Postgres username reference |
| `DB_PASS` | `${{Postgres.PGPASSWORD}}` | Railway Postgres password reference |
| `JWT_SECRET` | `<new random string, at least 64 characters>` | Unique production secret key (e.g. generate via `openssl rand -hex 32`) |
| `APP_ENV` | `production` | Enforces production security checks (fail-fast if JWT secret is short or default) |
| `APP_TIME_ZONE` | `Asia/Kolkata` | Application campus timezone |
| `CORS_ORIGINS` | `<set later in D3, the exact Vercel URL, e.g. https://your-frontend.vercel.app>` | Allowed origin for frontend requests |

> **IMPORTANT**:
> - **Do NOT use `DATABASE_PUBLIC_URL`** for the deployed backend service. Connecting over the public internet introduces unnecessary latency, egress costs, and security exposure. Always use the private reference variables shown above.
> - Railway exposes `DATABASE_URL` as `postgresql://...` which is **not** a valid JDBC URL. The explicit `DB_URL` format `jdbc:postgresql://...` defined above is required for Spring Boot.

### Step 2.4: Apply Changes and Redeploy
- When configuring variables in the Railway dashboard, changes are often **staged**.
- Make sure to click **Deploy** or **Apply changes** and trigger a redeploy so the running container picks up the newly set environment variables. Otherwise, the running container will continue running with old/missing variables.

### Step 2.5: Generate Public Domain
1. In the backend service, go to **Settings** -> **Networking**.
2. Under **Public Networking**, click **Generate Domain** (e.g., `peertutor-backend-production.up.railway.app`).

---

## 3. Verification

Once Railway reports the deployment as active and healthy:

1. **Verify Health Endpoint**:
   ```bash
   curl -i https://<your-backend-domain>/api/health
   ```
   **Expected Response** (HTTP 200 OK):
   ```json
   {
     "status": "UP",
     "timeZone": "Asia/Kolkata",
     "serverTime": "2026-10-17T16:30:00"
   }
   ```
   Verify that `status` is `UP`, `timeZone` is `Asia/Kolkata`, and `serverTime` reflects the current campus time.

2. **Verify Swagger UI**:
   Open in your browser:
   ```
   https://<your-backend-domain>/swagger-ui.html
   ```
   Verify that the interactive API documentation loads properly.

---

## 4. Troubleshooting Common Failures

### 1. Variables Not Applied
- **Symptom**: Application fails with missing configuration or default values even after you added environment variables in the dashboard.
- **Cause**: Variable updates in Railway dashboard are held in a "staged" state until committed/deployed.
- **Fix**: Review the banner at the top of the Variables tab and click **Apply Changes** / trigger a manual redeploy (**Redeploy** button).

### 2. "claims to not accept jdbcUrl"
- **Symptom**: HikariCP / PostgreSQL driver initialization error:
  `java.lang.RuntimeException: Driver org.postgresql.Driver claims to not accept jdbcUrl, ${{Postgres.RAILWAY_PRIVATE_DOMAIN}}...`
- **Cause**: A Railway reference variable did not resolve into a real value (often because the database service name was different from `Postgres`, e.g. named `postgresql` or `PostgreSQL` or misspelled).
- **Fix**: Inspect the database service name in your Railway project canvas. If it is named `PostgreSQL` or `db`, update the variable expression accordingly:
  `jdbc:postgresql://${{PostgreSQL.RAILWAY_PRIVATE_DOMAIN}}:${{PostgreSQL.PGPORT}}/${{PostgreSQL.PGDATABASE}}` or rename the database service to `Postgres`.

### 3. App Not Reachable
- **Symptom**: Railway deployment shows "Application failed to respond" or healthcheck times out on public domain.
- **Cause**: The application is not listening on the port dynamically assigned by Railway.
- **Fix**: Railway injects a dynamic `PORT` environment variable at container startup. Our `backend/src/main/resources/application.properties` specifies `server.port=${PORT:8080}`, which binds Spring Boot to Railway's injected port. Ensure `PORT` is not hardcoded or overridden in the Dockerfile.
