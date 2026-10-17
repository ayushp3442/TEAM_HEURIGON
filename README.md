# StudyCircle (Peer Tutoring Board)

**Learn Together. Grow Together.**

StudyCircle is a web app where students find senior students who solved the same courses last year, book a time slot with them, and keep asking doubts in a chat for 24 hours after the session.

| | |
|---|---|
| **Live project** | https://teamheurigon.vercel.app |
| **Demo video (3–5 min)** | `<PASTE YOUTUBE (UNLISTED) OR GOOGLE DRIVE LINK HERE>` |
| **Backend API (Railway)** | https://teamheurigon-production.up.railway.app/api |
| **API docs (Swagger UI)** | https://teamheurigon-production.up.railway.app/swagger-ui.html |

---

## Table of contents

1. [Problem](#problem)
2. [Solution](#solution)
3. [Features](#features)
4. [Tech stack](#tech-stack)
5. [Why this tech stack](#why-this-tech-stack)
6. [Architecture](#architecture)
7. [Setup and usage](#setup-and-usage)
8. [Deployment](#deployment)
9. [How to try the live app](#how-to-try-the-live-app)
10. [Team](#team)

---

## Problem

Students struggle with specific subjects and exams, while senior students who already cleared those subjects are happy to help. There is no simple, structured way to connect them. Help today is found through scattered group chats and word of mouth, which means:

- Students do not know who can help with which subject.
- Agreeing on a time and place takes long back-and-forth messages.
- Doubts that come up after a session have nowhere to go.

## Solution

StudyCircle gives campuses one board where **tutors publish real availability** and **students search, request and book it**. Tutors accept or decline each request. Once a session has ended, the student and tutor get a private chat for **24 hours**, so follow-up doubts are solved while the topic is fresh. After that the chat becomes read-only.

## Features

**Accounts and roles**
- Register and log in as a **Student** or a **Tutor** (JWT-based authentication, passwords stored as BCrypt hashes).
- Role-based access: only tutors can create profiles, post slots and accept or decline requests.

**For tutors**
- Create and edit a profile: bio, department, year of study and subjects taught (pick from the catalog or add a new subject).
- Post availability slots, either **Online** (meeting link) or **On-campus** (location).
- See incoming requests and **accept or decline** them. Accepting books the slot and auto-declines other pending requests for it.
- Delete their own slots if not booked.

**For students**
- Browse and **search tutors** by subject, mode (online or on-campus) and date. Only tutors with an open, future slot matching the filters are shown.
- Open a tutor, view open slots and **send a session request** with a message and subject.
- Track requests (Pending, Accepted, Declined, Cancelled) and cancel pending ones.
- See the meeting link or location once a request is accepted.

**Post-session chat (24-hour doubt solving)**
- A chat belongs to one accepted session and opens when the slot ends.
- It stays open for 24 hours after the slot ends, then becomes read-only.
- The window is calculated **on the server**, never trusted from the client.
- Only the student and tutor of that session can read or write.
- Chats list with live status (Open, Opens after session, Closed) and a countdown to closing; messages refresh by polling every 3 seconds.

**Safety and correctness**
- Double-booking protection (a slot can be accepted only once, with optimistic locking on slots).
- One request per student per slot (duplicate requests return a friendly `409`).
- A student cannot request their own slot, a booked slot, or a slot in the past.
- Consistent JSON error format for every error (`status`, `error`, `message`, `timestamp`).
- No fake data: the only seeded data is the subjects catalog. All users, slots, requests and messages come from real accounts.

## Tech stack

| Layer | Technology |
|---|---|
| Frontend | Flutter Web (Dart), `go_router`, `provider`, `dio`, `shared_preferences`, `intl` |
| Backend | Spring Boot 3.3.4, Java 17, Spring Web, Spring Data JPA (Hibernate), Bean Validation |
| Security | Spring Security, JWT (jjwt 0.12), BCrypt, CORS configuration |
| Database | PostgreSQL |
| API docs | springdoc-openapi (Swagger UI) |
| Hosting | Vercel (frontend), Railway (backend and PostgreSQL), Docker (backend image) |

## Why this tech stack

- **Flutter Web:** one codebase with a responsive layout (navigation rail on desktop, bottom bar on mobile widths), a polished UI quickly, and a path to Android and iOS later without a rewrite.
- **Spring Boot + Java 17:** a mature, well-structured way to build a REST API with clear layers (controller, service, repository). Bean Validation and a global exception handler give consistent, safe error responses.
- **Spring Security + JWT:** stateless authentication fits a separately hosted frontend and API, and scales without server-side sessions. Role checks (`STUDENT`, `TUTOR`) are enforced on the server.
- **PostgreSQL + JPA/Hibernate:** the data is relational (users, tutors, subjects, slots, requests, messages), and we rely on unique constraints, foreign keys and transactions to prevent double bookings and duplicate requests.
- **Polling for chat (instead of WebSockets):** simpler, reliable behind any proxy, and fast enough for a doubt-solving chat. It can be upgraded to WebSocket later.
- **Docker, Railway and Vercel:** the backend ships as a container with configuration only through environment variables, and the static Flutter build is served from a CDN with no server to maintain.

## Architecture

```
┌────────────────────────────────────────────────────┐
│              Flutter Web (browser)                 │
│  go_router · Provider · Dio · shared_preferences   │
└───────────────────────┬────────────────────────────┘
                        │  HTTPS / JSON
                        │  Authorization: Bearer <JWT>
┌───────────────────────▼────────────────────────────┐
│               Spring Boot REST API                 │
│  JwtAuthFilter → Controller → Service → Repository │
│  Bean Validation · GlobalExceptionHandler · CORS   │
└───────────────────────┬────────────────────────────┘
                        │  Spring Data JPA / Hibernate
┌───────────────────────▼────────────────────────────┐
│                   PostgreSQL                       │
│ users · tutor_profiles · subjects · tutor_subjects │
│ availability_slots · session_requests · chat_messages │
└────────────────────────────────────────────────────┘
```

Full design notes, the API contract and screen specs are in [`Architecture.md`](./Architecture.md).

**Repository layout**

```
peer-tutoring-board/
├── README.md
├── Architecture.md
├── docker-compose.yml     # local PostgreSQL
├── backend/               # Spring Boot API
└── frontend/              # Flutter Web app
```

## Setup and usage

### Prerequisites

- Java 17
- Flutter SDK (with web support enabled)
- Docker (for local PostgreSQL) or a local PostgreSQL install

### 1. Database

```bash
docker compose up -d
```

This starts PostgreSQL on port 5432 with database `peertutor` (user `postgres`, password `postgres`, **local development only**). Tables are created automatically on first start.

### 2. Backend

```bash
cd backend
./mvnw spring-boot:run
```

- API: http://localhost:8080/api
- Health check: http://localhost:8080/api/health
- Swagger UI: http://localhost:8080/swagger-ui.html

The backend is configured with environment variables:

| Variable | Purpose | Default |
|---|---|---|
| `DB_URL` | JDBC URL of PostgreSQL | `jdbc:postgresql://localhost:5432/peertutor` |
| `DB_USER` | Database user | `postgres` |
| `DB_PASS` | Database password | `postgres` |
| `JWT_SECRET` | Secret used to sign JWTs (at least 32 characters) | none, **required** |
| `CORS_ORIGINS` | Comma-separated allowed frontend origins, no trailing slash | `https://teamheurigon.vercel.app/` |
| `CORS_ORIGIN_PATTERNS` | Optional origin patterns, e.g. `https://*.vercel.app` | empty |
| `APP_TIME_ZONE` | Campus time zone for slot rules and chat window | `Asia/Kolkata` |
| `APP_ENV` | Environment name | `local` |
| `SHOW_SQL` | Log SQL statements | `false` |
| `DDL_AUTO` | Hibernate schema mode | `update` |
| `PORT` | HTTP port | `8080` |

For local development, set a JWT secret and allow the Flutter dev origin. Generate a secret with `python -c "import secrets; print(secrets.token_hex(32))"`, then:

```bash
# macOS / Linux
export JWT_SECRET=<your-generated-secret>
export CORS_ORIGINS=http://localhost:3000

# Windows PowerShell
$env:JWT_SECRET="<your-generated-secret>"
$env:CORS_ORIGINS="http://localhost:3000"
```

Never commit real secrets to the repository.

### 3. Frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome --web-port 3000
```

The API address is read at **build time**. By default it is `http://localhost:8080/api`. To point the app at another backend:

```bash
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://<host>:8080/api
```

### 4. Using the app

There are **no preloaded accounts**. Register at least one tutor and one student:

1. Open the app and click **Create account**. Choose **Tutor**, then create the tutor profile (bio, department, year, subjects).
2. As the tutor, **Add slot** (start at least 2 minutes from now, minimum duration 5 minutes by default).
3. In a second browser (or an incognito window), register a **Student**, open **Browse**, filter by subject, mode or date, open the tutor and **Request** the slot.
4. As the tutor, **accept** the request (it must be accepted before the slot starts).
5. After the slot ends, open **Chats**. Both sides can message for the next 24 hours.

Use two different browsers (or one normal and one incognito window), because the login token is stored in the browser's local storage and is shared between tabs of the same browser profile.

## Deployment

**Backend (Railway)**
- Built from `backend/Dockerfile`, with a PostgreSQL service reached over Railway's private network.
- Configured entirely by the environment variables listed above (`DB_URL`, `DB_USER`, `DB_PASS`, `JWT_SECRET`, `CORS_ORIGINS`, `APP_ENV`, `APP_TIME_ZONE`, `SHOW_SQL`).
- After changing variables, apply the changes and redeploy.

**Frontend (Vercel)**

The Flutter app is built locally and the static output is deployed:

```bash
cd frontend
flutter build web --release --dart-define=API_BASE_URL=https://teamheurigon-production.up.railway.app/api
# copy vercel.json (rewrites all paths to /index.html) into build/web, then:
vercel deploy build/web --prod
```

## How to try the live app

Open https://teamheurigon.vercel.app and register your own accounts. Nothing is preloaded, so any account you create works exactly the same way ours do. For the full chat experience, create a tutor slot of 5 minutes starting a few minutes from now, request and accept it, and the chat opens as soon as the slot ends.

## Team

**Team Heurigon**

| Name | Role |
|---|---|
| `<Member 1 name>` | Backend core (auth, security, database) |
| `<Member 2 name>` | Backend features (tutors, slots, requests) |
| `<Member 3 name>` | Frontend core (app shell, auth, chat) |
| `<Member 4 name>` | Frontend features (browse, dashboard, requests) |

*(Edit names and roles to match your team.)*

---

Built for the ACM Hackathon.
