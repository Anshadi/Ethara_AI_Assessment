# Team Task Manager

A full-stack web application for team project and task management with role-based access control.

## Features

- **Authentication**: User signup/login with JWT tokens
- **Role-Based Access**: Admin and Member roles with different permissions
- **Project Management**: Create projects and manage team members
- **Task Management**: Create, assign, and track task progress
- **Dashboard**: Real-time task statistics and overview
- **Responsive Design**: Modern UI built with Flutter

## Tech Stack

### Backend
- **Java 17** with Spring Boot 3.2
- **Spring Security** with JWT authentication
- **MySQL Database** for persistent storage
- **Maven** for build management

### Frontend
- **Flutter** for cross-platform web development
- **Material Design** UI components
- **HTTP** for API communication

## Quick Start

### Prerequisites
- Java JDK 17 or higher
- Maven 3.6 or higher
- Flutter SDK 3.x
- MySQL Database (local or Docker)

### Running Locally

1. **Clone the repository**
   ```bash
   git clone https://github.com/Anshadi/Ethara_AI_Assessment.git
   cd Ethara_AI_Assessment
   ```

2. **Build and Run**
   ```bash
   # For Windows
   run.bat
   
   # For Linux/Mac
   ./run.sh
   ```

3. **Access the Application**
   - Open your browser and navigate to `http://localhost:8081`

## Usage

### Admin Features
- Create and manage projects
- Add/remove team members
- Create and assign tasks to members
- View all tasks and their progress
- Delete tasks

### Member Features
- View assigned tasks
- Update task status
- View project details

## API Endpoints

### Authentication
- `POST /api/auth/signup` - User registration
- `POST /api/auth/login` - User login

### Projects
- `GET /api/projects` - Get user projects
- `POST /api/projects` - Create project (Admin only)
- `DELETE /api/projects/{id}` - Delete project (Admin only)

### Tasks
- `GET /api/tasks/my` - Get user's tasks
- `GET /api/tasks/all` - Get all tasks (Admin only)
- `POST /api/tasks` - Create task (Admin only)
- `PUT /api/tasks/{id}/status` - Update task status
- `DELETE /api/tasks/{id}` - Delete task (Admin only)

## Database Configuration

The application uses MySQL database for persistent storage. The configuration is already set up in `application.properties`:

```properties
spring.datasource.url=jdbc:mysql://localhost:3307/taskmanagerdb
spring.datasource.username=root
spring.datasource.password=root
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect
```

### Setting up MySQL with Docker

```bash
# Run MySQL container
docker run --name mysql-container -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=taskmanagerdb -p 3307:3306 -d mysql:8.0

# Create database (if needed)
docker exec -it mysql-container mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS taskmanagerdb;"
```

## Deployment

The application is ready for deployment on platforms like Railway, Heroku, or any cloud service with Java support.

## Project Structure

```
├── backend/
│   ├── src/main/java/com/taskmanager/
│   │   ├── controller/     # REST API controllers
│   │   ├── service/        # Business logic
│   │   ├── repository/     # Data access layer
│   │   ├── entity/         # Database entities
│   │   ├── dto/           # Data transfer objects
│   │   └── security/      # Security configuration
│   └── src/main/resources/
│       ├── static/        # Flutter web build
│       └── application.properties
└── frontend/
    ├── lib/
    │   ├── screens/       # Flutter screens
    │   ├── services/      # API services
    │   └── models/        # Data models
    └── pubspec.yaml
```

## License

This project is open source and available under the [MIT License](LICENSE).
