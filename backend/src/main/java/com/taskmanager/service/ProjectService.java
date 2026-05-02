package com.taskmanager.service;

import com.taskmanager.dto.AddMemberRequest;
import com.taskmanager.dto.ProjectRequest;
import com.taskmanager.dto.ProjectResponse;
import com.taskmanager.dto.UserResponse;
import com.taskmanager.entity.Project;
import com.taskmanager.entity.ProjectMember;
import com.taskmanager.entity.User;
import com.taskmanager.repository.ProjectMemberRepository;
import com.taskmanager.repository.ProjectRepository;
import com.taskmanager.repository.TaskRepository;
import com.taskmanager.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class ProjectService {

        private final ProjectRepository projectRepository;
        private final UserRepository userRepository;
        private final ProjectMemberRepository projectMemberRepository;
        private final TaskRepository taskRepository;

        public ProjectService(ProjectRepository projectRepository, UserRepository userRepository,
                        ProjectMemberRepository projectMemberRepository, TaskRepository taskRepository) {
                this.projectRepository = projectRepository;
                this.userRepository = userRepository;
                this.projectMemberRepository = projectMemberRepository;
                this.taskRepository = taskRepository;
        }

        public ProjectResponse createProject(ProjectRequest request, Long createdBy) {
                User user = userRepository.findById(createdBy)
                                .orElseThrow(() -> new RuntimeException("User not found"));

                Project project = new Project();
                project.setName(request.getName());
                project.setDescription(request.getDescription());
                project.setCreatedBy(user);

                project = projectRepository.save(project);

                // Add creator as a member
                ProjectMember member = new ProjectMember();
                member.setUser(user);
                member.setProject(project);
                projectMemberRepository.save(member);

                return new ProjectResponse(
                                project.getId(),
                                project.getName(),
                                project.getDescription(),
                                project.getCreatedBy().getId(),
                                project.getCreatedBy().getName());
        }

        public List<ProjectResponse> getUserProjects(Long userId) {
                List<Project> projects = projectRepository.findByMembersUserId(userId);
                return projects.stream()
                                .map(project -> new ProjectResponse(
                                                project.getId(),
                                                project.getName(),
                                                project.getDescription(),
                                                project.getCreatedBy().getId(),
                                                project.getCreatedBy().getName()))
                                .collect(Collectors.toList());
        }

        public void addMember(Long projectId, AddMemberRequest request) {
                Project project = projectRepository.findById(projectId)
                                .orElseThrow(() -> new RuntimeException("Project not found"));

                User user = userRepository.findById(request.getUserId())
                                .orElseThrow(() -> new RuntimeException("User not found"));

                if (projectMemberRepository.existsByUserIdAndProjectId(request.getUserId(), projectId)) {
                        throw new RuntimeException("User is already a member of this project");
                }

                ProjectMember member = new ProjectMember();
                member.setUser(user);
                member.setProject(project);
                projectMemberRepository.save(member);
        }

        public void deleteProject(Long projectId, Long userId, String role) {
                Project project = projectRepository.findById(projectId)
                                .orElseThrow(() -> new RuntimeException("Project not found"));

                // Only admin or project creator can delete
                if (!project.getCreatedBy().getId().equals(userId) && !role.equals("ADMIN")) {
                        throw new RuntimeException("You are not authorized to delete this project");
                }

                try {
                        // Explicitly delete associated tasks and members to satisfy foreign key constraints
                        taskRepository.deleteByProjectId(projectId);
                        projectMemberRepository.deleteByProjectId(projectId);
                        
                        // Now delete the project
                        projectRepository.delete(project);
                        projectRepository.flush(); 
                } catch (Exception e) {
                        throw new RuntimeException("Failed to delete project: " + e.getMessage());
                }
        }

        public List<UserResponse> getProjectMembers(Long projectId) {
                if (!projectRepository.existsById(projectId)) {
                        throw new RuntimeException("Project not found");
                }

                return projectMemberRepository.findByProjectId(projectId).stream()
                                .map(member -> new UserResponse(
                                                member.getUser().getId(),
                                                member.getUser().getName(),
                                                member.getUser().getEmail(),
                                                member.getUser().getRole().name()))
                                .collect(Collectors.toList());
        }

        public void removeMember(Long projectId, Long userId, Long requestingUserId, String role) {
                Project project = projectRepository.findById(projectId)
                                .orElseThrow(() -> new RuntimeException("Project not found"));

                // Only admin or project creator can remove members
                if (!project.getCreatedBy().getId().equals(requestingUserId) && !role.equals("ADMIN")) {
                        throw new RuntimeException("You are not authorized to remove members from this project");
                }

                // Cannot remove the project creator
                if (project.getCreatedBy().getId().equals(userId)) {
                        throw new RuntimeException("Cannot remove the project creator");
                }

                ProjectMember member = projectMemberRepository.findByUserIdAndProjectId(userId, projectId)
                                .orElseThrow(() -> new RuntimeException("User is not a member of this project"));

                projectMemberRepository.delete(member);
        }
}
