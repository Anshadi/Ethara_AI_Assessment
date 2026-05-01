package com.taskmanager.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DashboardResponse {
    private Long total;
    private Long todo;
    private Long inProgress;
    private Long done;
    private Long overdue;
}
