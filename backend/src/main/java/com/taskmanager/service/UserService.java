package com.taskmanager.service;

import com.taskmanager.entity.User;
import com.taskmanager.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    
    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }
    
    public void promoteToAdmin(Long userId, Long requestingUserId, String requestingRole) {
        // Only existing admin can promote others
        User requestingUser = userRepository.findById(requestingUserId)
                .orElseThrow(() -> new RuntimeException("Requesting user not found"));
        
        if (!requestingUser.getRole().equals(User.Role.ADMIN)) {
            throw new RuntimeException("Only admins can promote users to admin");
        }
        
        User userToPromote = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        if (userToPromote.getRole().equals(User.Role.ADMIN)) {
            throw new RuntimeException("User is already an admin");
        }
        
        userToPromote.setRole(User.Role.ADMIN);
        userRepository.save(userToPromote);
    }
    
    public void demoteFromAdmin(Long userId, Long requestingUserId, String requestingRole) {
        // Only existing admin can demote others
        User requestingUser = userRepository.findById(requestingUserId)
                .orElseThrow(() -> new RuntimeException("Requesting user not found"));
        
        if (!requestingUser.getRole().equals(User.Role.ADMIN)) {
            throw new RuntimeException("Only admins can demote users from admin");
        }
        
        User userToDemote = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        if (!userToDemote.getRole().equals(User.Role.ADMIN)) {
            throw new RuntimeException("User is not an admin");
        }
        
        if (userToDemote.getId().equals(requestingUserId)) {
            throw new RuntimeException("Cannot demote yourself from admin");
        }
        
        // Ensure there's at least one admin left
        long adminCount = userRepository.countByRole(User.Role.ADMIN);
        if (adminCount <= 1) {
            throw new RuntimeException("Cannot demote the last admin");
        }
        
        userToDemote.setRole(User.Role.MEMBER);
        userRepository.save(userToDemote);
    }
}
