package com.taskmanager.service;

import com.taskmanager.dto.DashboardResponse;
import com.taskmanager.entity.Task;
import com.taskmanager.repository.TaskRepository;
import com.taskmanager.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class DashboardService {

    private final TaskRepository taskRepository;
    private final UserRepository userRepository;

    public DashboardService(TaskRepository taskRepository, UserRepository userRepository) {
        this.taskRepository = taskRepository;
        this.userRepository = userRepository;
    }

    public DashboardResponse getDashboard(Long userId) {
        userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<Task> allTasks = taskRepository.findByAssignedToId(userId);

        long total = allTasks.size();
        long todo = allTasks.stream().filter(t -> t.getStatus() == Task.TaskStatus.TODO).count();
        long inProgress = allTasks.stream().filter(t -> t.getStatus() == Task.TaskStatus.IN_PROGRESS).count();
        long done = allTasks.stream().filter(t -> t.getStatus() == Task.TaskStatus.DONE).count();

        LocalDate today = LocalDate.now();
        long overdue = allTasks.stream()
                .filter(t -> t.getDueDate() != null)
                .filter(t -> t.getDueDate().isBefore(today))
                .filter(t -> t.getStatus() != Task.TaskStatus.DONE)
                .count();

        return new DashboardResponse(total, todo, inProgress, done, overdue);
    }
}
