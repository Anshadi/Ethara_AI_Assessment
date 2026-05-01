package com.taskmanager.repository;

import com.taskmanager.entity.Task;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface TaskRepository extends JpaRepository<Task, Long> {
    List<Task> findByAssignedToId(Long userId);
    List<Task> findByDueDateBeforeAndStatusNot(LocalDate dueDate, Task.TaskStatus status);
}
