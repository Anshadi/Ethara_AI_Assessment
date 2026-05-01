package com.taskmanager.controller;

import com.taskmanager.dto.AddMemberRequest;
import com.taskmanager.dto.ProjectRequest;
import com.taskmanager.dto.ProjectResponse;
import com.taskmanager.dto.UserResponse;
import com.taskmanager.service.ProjectService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/projects")
public class ProjectController {

    private final ProjectService projectService;

    public ProjectController(ProjectService projectService) {
        this.projectService = projectService;
    }

    @PostMapping
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public ResponseEntity<ProjectResponse> createProject(@Valid @RequestBody ProjectRequest request,
            Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        ProjectResponse response = projectService.createProject(request, userId);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<List<ProjectResponse>> getUserProjects(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        List<ProjectResponse> projects = projectService.getUserProjects(userId);
        return ResponseEntity.ok(projects);
    }

    @PostMapping("/{projectId}/members")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public ResponseEntity<Void> addMember(@PathVariable Long projectId,
            @Valid @RequestBody AddMemberRequest request) {
        projectService.addMember(projectId, request);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{projectId}")
    public ResponseEntity<Void> deleteProject(@PathVariable Long projectId,
            Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        String role = authentication.getAuthorities().iterator().next().getAuthority();
        projectService.deleteProject(projectId, userId, role);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{projectId}/members")
    public ResponseEntity<List<UserResponse>> getProjectMembers(@PathVariable Long projectId,
            Authentication authentication) {
        List<UserResponse> members = projectService.getProjectMembers(projectId);
        return ResponseEntity.ok(members);
    }

    @DeleteMapping("/{projectId}/members/{userId}")
    public ResponseEntity<Void> removeMember(@PathVariable Long projectId,
            @PathVariable Long userId,
            Authentication authentication) {
        Long requestingUserId = (Long) authentication.getPrincipal();
        String role = authentication.getAuthorities().iterator().next().getAuthority();
        projectService.removeMember(projectId, userId, requestingUserId, role);
        return ResponseEntity.ok().build();
    }
}
