package com.taskmanager.controller;

import com.taskmanager.dto.UserResponse;
import com.taskmanager.entity.User;
import com.taskmanager.repository.UserRepository;
import com.taskmanager.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserRepository userRepository;
    private final UserService userService;

    public UserController(UserRepository userRepository, UserService userService) {
        this.userRepository = userRepository;
        this.userService = userService;
    }

    @GetMapping
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public ResponseEntity<List<UserResponse>> getAllUsers() {
        List<User> users = userRepository.findAll();
        List<UserResponse> userResponses = users.stream()
                .map(user -> new UserResponse(
                        user.getId(),
                        user.getName(),
                        user.getEmail(),
                        user.getRole().name()))
                .collect(Collectors.toList());
        return ResponseEntity.ok(userResponses);
    }

    @PutMapping("/{userId}/promote-admin")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public ResponseEntity<Void> promoteToAdmin(@PathVariable Long userId, Authentication authentication) {
        Long requestingUserId = (Long) authentication.getPrincipal();
        String requestingRole = authentication.getAuthorities().iterator().next().getAuthority();
        userService.promoteToAdmin(userId, requestingUserId, requestingRole);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{userId}/demote-admin")
    @PreAuthorize("hasAuthority('ROLE_ADMIN')")
    public ResponseEntity<Void> demoteFromAdmin(@PathVariable Long userId, Authentication authentication) {
        Long requestingUserId = (Long) authentication.getPrincipal();
        String requestingRole = authentication.getAuthorities().iterator().next().getAuthority();
        userService.demoteFromAdmin(userId, requestingUserId, requestingRole);
        return ResponseEntity.ok().build();
    }
}
