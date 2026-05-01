package com.taskmanager.controller;

import com.taskmanager.dto.TaskRequest;
import com.taskmanager.dto.TaskResponse;
import com.taskmanager.dto.UpdateStatusRequest;
import com.taskmanager.service.TaskService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tasks")
public class TaskController {

    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }

    @PostMapping
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public ResponseEntity<TaskResponse> createTask(@Valid @RequestBody TaskRequest request) {
        TaskResponse response = taskService.createTask(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/my")
    public ResponseEntity<List<TaskResponse>> getMyTasks(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        List<TaskResponse> tasks = taskService.getMyTasks(userId);
        return ResponseEntity.ok(tasks);
    }

    @GetMapping("/all")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public ResponseEntity<List<TaskResponse>> getAllTasks() {
        List<TaskResponse> tasks = taskService.getAllTasks();
        return ResponseEntity.ok(tasks);
    }

    @PutMapping("/{taskId}/status")
    public ResponseEntity<Void> updateTaskStatus(@PathVariable Long taskId,
            @Valid @RequestBody UpdateStatusRequest request,
            Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        String role = authentication.getAuthorities().iterator().next().getAuthority().replace("ROLE_", "");
        taskService.updateTaskStatus(taskId, request, userId, role);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{taskId}")
    public ResponseEntity<Void> deleteTask(@PathVariable Long taskId,
            Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        String role = authentication.getAuthorities().iterator().next().getAuthority().replace("ROLE_", "");
        taskService.deleteTask(taskId, userId, role);
        return ResponseEntity.ok().build();
    }
}
