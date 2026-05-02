# Team Task Manager

A professional full-stack project and task management system designed for collaborative team environments. This application provides a streamlined workflow for project leads and members to track progress, manage assignments, and maintain visibility over team productivity.

## Core Features

- **Robust Security**: Secure user registration and login powered by JWT (JSON Web Tokens).
- **Advanced Role-Based Access (RBAC)**: Distinct permissions for `ADMIN` and `MEMBER` roles to ensure data integrity and proper authorization.
- **Dynamic Project Control**:
  - Administrative creation and deletion of projects.
  - Seamless team member management (adding and removing participants).
- **Intelligent Task Tracking**:
  - Detailed task creation with descriptions and due dates.
  - Granular assignment capabilities to specific project members.
  - Real-time status updates (Todo, In Progress, Done).
- **Analytical Dashboard**:
  - High-level overview of project health and task counts.
  - **Team Workload Visualization**: Dedicated admin view to monitor member performance and task distribution.
  - **Dynamic Status Reporting**: Smart alerts for overdue tasks and pending workloads.

## Technical Architecture

The system utilizes a modern, scalable tech stack to deliver a high-performance experience:

### Backend Architecture
- **Framework**: Java 17 with Spring Boot 3.2.
- **Security**: Spring Security integrated with JWT for stateless authentication.
- **Data Layer**: Hibernate/JPA for efficient object-relational mapping.
- **Database**: MySQL 8.0 for persistent, reliable storage.
- **Transaction Management**: Atomic operations for complex deletions and updates.

### Frontend Experience
- **Framework**: Flutter Web for a responsive, single-page application (SPA) experience.
- **UI/UX**: Clean, modern Material Design interface with custom interactive components.
- **State Management**: Reactive UI updates based on real-time API feedback.

## Deployment & Execution

### Prerequisites
- Java JDK 17+
- Maven 3.6+
- Flutter SDK 3.x
- MySQL Instance (Accessible via Docker or Local Installation)

### Quick Start Guide

1. **Database Setup**:
   Ensure a MySQL database is running. If using Docker:
   ```bash
   docker run --name mysql-container -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=taskmanagerdb -p 3307:3306 -d mysql:8.0
   ```

2. **Frontend Build**:
   Navigate to the `frontend` directory and compile the web application:
   ```bash
   cd frontend
   flutter build web
   ```

3. **Backend Integration**:
   Copy the generated build from `frontend/build/web` to `backend/src/main/resources/static`.

4. **Launch Application**:
   Navigate to the `backend` directory and start the Spring Boot server:
   ```bash
   cd backend
   mvn spring-boot:run
   ```
   The application will be accessible at `http://localhost:8081`.

## Project Organization

The repository is structured to separate concerns and facilitate easy maintenance:

### Backend Structure (`backend/`)
- **`src/main/java/com/taskmanager/`**: Core Java package
  - **`controller/`**: REST API controllers for authentication, projects, tasks
  - **`service/`**: Business logic layer
  - **`repository/`**: Data access layer with JPA repositories
  - **`entity/`**: JPA entities (User, Project, Task, ProjectMember)
  - **`dto/`**: Data Transfer Objects for API requests/responses
  - **`security/`**: JWT authentication and Spring Security configuration
  - **`config/`**: Application configuration classes
- **`src/main/resources/`**: Configuration and static files
  - **`static/`**: Compiled Flutter web application
  - **`application.properties`**: Database and application settings

### Frontend Structure (`frontend/`)
- **`lib/`**: Flutter source code
  - **`screens/`**: UI screens (ProjectsScreen, MyTasksScreen, LoginScreen)
  - **`services/`**: API service layer for backend communication
  - **`models/`**: Dart models for data structures
  - **`widgets/`**: Reusable UI components
  - **`main.dart`**: Application entry point
- **`build/web/`**: Compiled web application (deployed to backend)

### Key Files
- **`.gitignore`**: Git ignore configuration for both backend and frontend
- **`README.md`**: Project documentation and setup instructions

---
*This platform demonstrates a complete end-to-end integration of modern web technologies to solve real-world project management challenges.*
