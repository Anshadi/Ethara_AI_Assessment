package com.taskmanager.service;

import com.taskmanager.dto.DashboardResponse;
import com.taskmanager.dto.MemberWorkloadResponse;
import com.taskmanager.entity.Task;
import com.taskmanager.entity.User;
import com.taskmanager.repository.TaskRepository;
import com.taskmanager.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class DashboardService {

    private final TaskRepository taskRepository;
    private final UserRepository userRepository;

    public DashboardService(TaskRepository taskRepository, UserRepository userRepository) {
        this.taskRepository = taskRepository;
        this.userRepository = userRepository;
    }

    public DashboardResponse getDashboard(Long userId, String role) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<Task> allTasks;
        if ("ADMIN".equals(role)) {
            // Admin sees everything
            allTasks = taskRepository.findAll();
        } else {
            // Member only sees their assigned tasks
            allTasks = taskRepository.findByAssignedToId(userId);
        }

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

        List<MemberWorkloadResponse> workload = new ArrayList<>();
        if ("ADMIN".equals(role)) {
            Map<User, List<Task>> tasksByUser = allTasks.stream()
                    .collect(Collectors.groupingBy(Task::getAssignedTo));
            
            workload = tasksByUser.entrySet().stream()
                    .map(entry -> {
                        User u = entry.getKey();
                        List<Task> userTasks = entry.getValue();
                        long userTotal = userTasks.size();
                        long userDone = userTasks.stream().filter(t -> t.getStatus() == Task.TaskStatus.DONE).count();
                        return new MemberWorkloadResponse(u.getName(), userTotal, userDone);
                    })
                    .collect(Collectors.toList());
        }

        return new DashboardResponse(total, todo, inProgress, done, overdue, workload);
    }
}
