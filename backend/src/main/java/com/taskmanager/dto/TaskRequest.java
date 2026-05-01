package com.taskmanager.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TaskRequest {
    @NotBlank(message = "Task title is required")
    private String title;

    private String description;

    @NotNull(message = "Project ID is required")
    private Long projectId;

    @NotNull(message = "Assigned to user ID is required")
    private Long assignedTo;

    private LocalDate dueDate;

    private String priority;
}
