import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import 'projects_screen.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  final _apiService = ApiService();
  List<dynamic> _tasks = [];
  List<dynamic> _projects = [];
  List<dynamic> _users = [];
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadUserRole();
    await _loadTasks();
    await _loadUsers();
  }

  Future<void> _loadUserRole() async {
    final role = await _apiService.getRole();
    setState(() => _userRole = role);
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = _userRole == 'ADMIN'
          ? await _apiService.getAllTasks()
          : await _apiService.getMyTasks();
      final projects = await _apiService.getProjects();
      setState(() {
        _tasks = tasks;
        _projects = projects;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: $e')),
        );
      }
    }
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _apiService.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showCreateTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime? selectedDueDate;
    int? selectedProjectId;
    int? selectedUserId;
    String selectedPriority = 'MEDIUM';
    bool isCreating = false;
    List<dynamic> projectMembers = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Create New Task', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter a task title';
                      if (v.trim().length < 3) return 'Minimum 3 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Project',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.folder_outlined),
                    ),
                    items: _projects.map((p) {
                      return DropdownMenuItem<int>(value: p['id'], child: Text(p['name']));
                    }).toList(),
                    onChanged: (v) async {
                      setDialogState(() {
                        selectedProjectId = v;
                        selectedUserId = null; // Reset user selection when project changes
                        projectMembers = []; // Reset members list
                      });
                      if (v != null) {
                        try {
                          final members = await _apiService.getProjectMembers(v);
                          final currentUserId = await _apiService.getUserId();
                          setDialogState(() {
                            // Filter out the current user (person creating the task)
                            projectMembers = members.where((m) => m['id'] != currentUserId).toList();
                          });
                        } catch (e) {
                          print('Error loading members: $e');
                        }
                      }
                    },
                    validator: (v) => v == null ? 'Please select a project' : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Assign To',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                    items: projectMembers.map((u) {
                      return DropdownMenuItem<int>(
                        value: u['id'],
                        child: Text('${u['name']} (${u['role']})'),
                      );
                    }).toList(),
                    onChanged: (v) => setDialogState(() => selectedUserId = v),
                    validator: (v) => v == null ? 'Please select a user' : null,
                    hint: selectedProjectId == null 
                        ? const Text('Select a project first')
                        : projectMembers.isEmpty 
                            ? const Text('No members available')
                            : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                    value: selectedPriority,
                    items: const [
                      DropdownMenuItem(value: 'LOW', child: Text('Low')),
                      DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                      DropdownMenuItem(value: 'HIGH', child: Text('High')),
                    ],
                    onChanged: (v) => setDialogState(() => selectedPriority = v!),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setDialogState(() => selectedDueDate = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        selectedDueDate != null
                            ? '${selectedDueDate!.year}-${selectedDueDate!.month.toString().padLeft(2, '0')}-${selectedDueDate!.day.toString().padLeft(2, '0')}'
                            : 'Select due date',
                        style: TextStyle(
                          color: selectedDueDate != null ? Colors.black87 : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isCreating
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isCreating = true);
                      try {
                        await _apiService.createTask(
                          titleController.text.trim(),
                          descriptionController.text.trim(),
                          selectedPriority,
                          selectedProjectId!,
                          selectedUserId!,
                          selectedDueDate != null
                              ? '${selectedDueDate!.year}-${selectedDueDate!.month.toString().padLeft(2, '0')}-${selectedDueDate!.day.toString().padLeft(2, '0')}'
                              : null,
                        );
                        Navigator.pop(context);
                        await _loadTasks();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Task created successfully')),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isCreating = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error creating task: $e')),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isCreating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH': return const Color(0xFFC62828);
      case 'MEDIUM': return const Color(0xFFE65100);
      case 'LOW': return const Color(0xFF2E7D32);
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'TODO': return const Color(0xFFE65100);
      case 'IN_PROGRESS': return const Color(0xFF6A1B9A);
      case 'DONE': return const Color(0xFF2E7D32);
      default: return Colors.grey;
    }
  }

  String _getStatusDisplay(String status) {
    switch (status.toUpperCase()) {
      case 'TODO': return 'To Do';
      case 'IN_PROGRESS': return 'In Progress';
      case 'DONE': return 'Done';
      default: return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'TODO': return Icons.radio_button_unchecked;
      case 'IN_PROGRESS': return Icons.sync_rounded;
      case 'DONE': return Icons.check_circle_outline;
      default: return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1565C0),
        title: Text(
          _userRole == 'ADMIN' ? 'All Tasks' : 'My Tasks',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)))
          : _tasks.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: const Color(0xFF1565C0),
                  onRefresh: _loadTasks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) => _buildTaskCard(_tasks[index]),
                  ),
                ),
      bottomNavigationBar: _buildBottomNav(context, 2),
      floatingActionButton: _userRole == 'ADMIN'
          ? FloatingActionButton.extended(
              onPressed: _showCreateTaskDialog,
              backgroundColor: const Color(0xFF1565C0),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('New Task', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    final isAdmin = _userRole == 'ADMIN';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.task_alt_rounded, size: 60, color: Color(0xFF1565C0)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No tasks yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(height: 8),
          Text(
            isAdmin
                ? 'Tap the button below to create your first task'
                : 'Tasks assigned to you will appear here',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final status = task['status'] as String? ?? 'TODO';
    final priority = task['priority'] as String? ?? 'MEDIUM';
    final statusColor = _getStatusColor(status);
    final priorityColor = _getPriorityColor(priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildChip(priority.substring(0, 1) + priority.substring(1).toLowerCase(), priorityColor),
                  ],
                ),
                if (task['description'] != null && task['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    task['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF757575), fontSize: 13),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.folder_outlined, size: 14, color: Color(0xFF757575)),
                    const SizedBox(width: 4),
                    Text(
                      task['projectName'] ?? 'Unknown',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                    ),
                    if (_userRole == 'ADMIN' && task['assignedToName'] != null) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.person_outline, size: 14, color: Color(0xFF757575)),
                      const SizedBox(width: 4),
                      Text(
                        task['assignedToName'],
                        style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                      ),
                    ],
                    if (task['dueDate'] != null) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF757575)),
                      const SizedBox(width: 4),
                      Text(
                        task['dueDate'],
                        style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(_getStatusIcon(status), size: 16, color: statusColor),
                    const SizedBox(width: 4),
                    _buildChip(_getStatusDisplay(status), statusColor),
                    const Spacer(),
                    PopupMenuButton<String>(
                      tooltip: 'Change status',
                      icon: const Icon(Icons.more_vert, color: Color(0xFF757575)),
                      onSelected: (newStatus) async {
                        try {
                          await _apiService.updateTaskStatus(task['id'], newStatus);
                          await _loadTasks();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Status updated')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      itemBuilder: (_) => <PopupMenuEntry<String>>[
                        const PopupMenuItem(value: 'TODO', child: Text('To Do')),
                        const PopupMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
                        const PopupMenuItem(value: 'DONE', child: Text('Done')),
                        if (_userRole == 'ADMIN') ...[
                          const PopupMenuDivider(),
                          PopupMenuItem<String>(
                            onTap: () => _deleteTask(task['id'], task['title']),
                            child: const Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _deleteTask(int taskId, String taskTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task'),
        content: Text('Delete "$taskTitle"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _apiService.deleteTask(taskId);
      await _loadTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting task: $e')),
        );
      }
    }
  }

  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF1565C0),
      unselectedItemColor: Colors.grey.shade400,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      elevation: 16,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
        } else if (index == 1) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const ProjectsScreen()));
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.folder_rounded), label: 'Projects'),
        BottomNavigationBarItem(icon: Icon(Icons.task_alt_rounded), label: 'Tasks'),
      ],
    );
  }
}
