package com.taskmanager.dto;

import com.taskmanager.entity.Task;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TaskResponse {
    private Long id;
    private String title;
    private String description;
    private String priority;
    private String status;
    private Long assignedTo;
    private String assignedToName;
    private Long projectId;
    private String projectName;
    private LocalDate dueDate;

    public static TaskResponse fromEntity(Task task) {
        return new TaskResponse(
                task.getId(),
                task.getTitle(),
                task.getDescription(),
                task.getPriority().name(),
                task.getStatus().name(),
                task.getAssignedTo().getId(),
                task.getAssignedTo().getName(),
                task.getProject().getId(),
                task.getProject().getName(),
                task.getDueDate());
    }
}
