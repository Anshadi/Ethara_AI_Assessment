# Team Task Manager

A professional full-stack project and task management system designed for collaborative team environments. This application provides a streamlined workflow for project leads and members to track progress, manage assignments, and maintain visibility over team productivity.

## Core Features

- **Robust Security**: User registration and login with JWT (JSON Web Tokens).
- **Role-Based Access (RBAC)**: Distinct permissions for `ADMIN` and `MEMBER` roles.
- **Dynamic Project Control**:
  - Create and delete projects.
  - Add and remove team members from projects.
- **Task Management**:
  - Create tasks with descriptions and due dates.
  - Assign tasks to project members.
  - Update task status across Todo, In Progress, and Done.
- **Dashboard Analytics**:
  - Overview of project health and task counts.
  - Workload visualization for team members.
  - Overdue task reporting.

## Technical Architecture

### Backend Architecture

- **Framework**: Java 17 with Spring Boot.
- **Security**: Spring Security + JWT authentication.
- **Data Layer**: Hibernate/JPA.
- **Database**: MySQL.
- **Health Check**: `/api/health` endpoint for deployment monitoring.

### Frontend Experience

- **Framework**: Flutter Web.
- **Routing**: Login, signup, dashboard, projects, and my tasks screens.
- **API Layer**: Uses relative API paths via `frontend/lib/config/app_config.dart`.

## Deployment & Execution

### Railway Deployment

The project now includes Railway deployment configuration in `railway.toml`.

#### Required Railway environment variables

Set these values in the Railway project settings:

- `DATABASE_URL`
  - Example: `jdbc:mysql://<host>:<port>/taskmanagerdb`
  - Use the Railway MySQL connection string if you add a MySQL plugin.
- `DB_USERNAME`
  - Example: `root`
- `DB_PASSWORD`
  - Your MySQL password.
- `JWT_SECRET`
  - A strong secret for JWT signing.
  - Do not keep the placeholder value in production.
- `JWT_EXPIRATION`
  - Example: `3600000`
  - Token lifetime in milliseconds (1 hour).

> Railway automatically provides the runtime `PORT` variable, which is already supported by `backend/src/main/resources/application.properties`.

#### Important deployment settings

- `healthcheckPath = "/api/health"`
- `restartPolicyType = "ON_FAILURE"`

### Local Development

#### Prerequisites

- Java JDK 17+
- Maven 3.6+
- Flutter SDK 3.x
- MySQL instance (Docker or local install)

#### Local setup steps

1. **Database**

   ```bash
   docker run --name mysql-container -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=taskmanagerdb -p 3307:3306 -d mysql:8.0
   ```

2. **Build frontend**

   ```bash
   cd frontend
   flutter build web
   ```

3. **Copy frontend build**
   Copy `frontend/build/web` into `backend/src/main/resources/static`.

4. **Run backend**

   ```bash
   cd backend
   mvn spring-boot:run
   ```

5. **Browse**
   Open `http://localhost:8081`.

## Project Organization

### Backend Structure (`backend/`)

- `src/main/java/com/taskmanager/`
  - `controller/`: REST controllers
  - `service/`: business logic
  - `repository/`: JPA repositories
  - `entity/`: database entities
  - `dto/`: request/response DTOs
  - `security/`: JWT and Spring Security
  - `config/`: configuration classes
- `src/main/resources/`
  - `static/`: compiled Flutter frontend assets
  - `application.properties`: runtime configuration

### Frontend Structure (`frontend/`)

- `lib/`
  - `screens/`: UI screens
  - `services/`: backend API integration
  - `models/`: Dart data models
  - `config/`: app configuration
  - `main.dart`: entry point
- `build/web/`: compiled Flutter web app

### Key Files

- `railway.toml`: Railway deployment configuration
- `backend/src/main/resources/application.properties`: environment-aware backend settings
- `frontend/lib/config/app_config.dart`: deployable API routing config
- `README.md`: documentation and setup instructions

---

This repository is designed for both local development and deployment on Railway with environment-based configuration and a backend-served Flutter web frontend.
