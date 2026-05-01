package com.taskmanager.service;

import com.taskmanager.dto.TaskRequest;
import com.taskmanager.dto.TaskResponse;
import com.taskmanager.dto.UpdateStatusRequest;
import com.taskmanager.entity.Project;
import com.taskmanager.entity.Task;
import com.taskmanager.entity.User;
import com.taskmanager.repository.ProjectMemberRepository;
import com.taskmanager.repository.ProjectRepository;
import com.taskmanager.repository.TaskRepository;
import com.taskmanager.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class TaskService {

    private final TaskRepository taskRepository;
    private final UserRepository userRepository;
    private final ProjectRepository projectRepository;
    private final ProjectMemberRepository projectMemberRepository;

    public TaskService(TaskRepository taskRepository, UserRepository userRepository,
            ProjectRepository projectRepository, ProjectMemberRepository projectMemberRepository) {
        this.taskRepository = taskRepository;
        this.userRepository = userRepository;
        this.projectRepository = projectRepository;
        this.projectMemberRepository = projectMemberRepository;
    }

    public TaskResponse createTask(TaskRequest request) {
        User assignedTo = userRepository.findById(request.getAssignedTo())
                .orElseThrow(() -> new RuntimeException("User not found"));

        Project project = projectRepository.findById(request.getProjectId())
                .orElseThrow(() -> new RuntimeException("Project not found"));

        // Check if user is a member of the project
        if (!projectMemberRepository.existsByUserIdAndProjectId(request.getAssignedTo(), request.getProjectId())) {
            throw new RuntimeException("User is not a member of this project");
        }

        Task task = new Task();
        task.setTitle(request.getTitle());
        task.setDescription(request.getDescription());
        task.setPriority(request.getPriority() != null
                ? Task.TaskPriority.valueOf(request.getPriority().toUpperCase())
                : Task.TaskPriority.MEDIUM);
        task.setStatus(Task.TaskStatus.TODO);
        task.setAssignedTo(assignedTo);
        task.setProject(project);
        task.setDueDate(request.getDueDate());

        task = taskRepository.save(task);
        return TaskResponse.fromEntity(task);
    }

    public List<TaskResponse> getMyTasks(Long userId) {
        List<Task> tasks = taskRepository.findByAssignedToId(userId);
        return tasks.stream()
                .map(TaskResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public void updateTaskStatus(Long taskId, UpdateStatusRequest request, Long userId, String role) {
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Task not found"));

        // Only assigned user or admin can update
        if (!task.getAssignedTo().getId().equals(userId) && !role.equals("ADMIN")) {
            throw new RuntimeException("You are not authorized to update this task");
        }

        try {
            Task.TaskStatus newStatus = Task.TaskStatus.valueOf(request.getStatus().toUpperCase());
            task.setStatus(newStatus);
            taskRepository.save(task);
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Invalid status. Valid values are: TODO, IN_PROGRESS, DONE");
        }
    }

    public void deleteTask(Long taskId, Long userId, String role) {
        // Only admin can delete tasks
        if (!role.equals("ADMIN")) {
            throw new RuntimeException("Only admins can delete tasks");
        }

        if (!taskRepository.existsById(taskId)) {
            throw new RuntimeException("Task not found");
        }

        taskRepository.deleteById(taskId);
    }

    public List<TaskResponse> getAllTasks() {
        List<Task> tasks = taskRepository.findAll();
        return tasks.stream()
                .map(TaskResponse::fromEntity)
                .collect(Collectors.toList());
    }
}
