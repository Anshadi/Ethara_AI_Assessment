import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import 'my_tasks_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final _apiService = ApiService();
  List<dynamic> _projects = [];
  bool _isLoading = true;
  bool _isActionLoading = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadUserRole();
    await _loadProjects();
  }

  Future<void> _loadUserRole() async {
    final role = await _apiService.getRole();
    setState(() => _userRole = role);
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await _apiService.getProjects();
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading projects: $e')),
        );
      }
    }
  }

  void _showCreateProjectDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isCreating = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Create New Project', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Project Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.folder_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter a project name';
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
                        await _apiService.createProject(
                          nameController.text.trim(),
                          descriptionController.text.trim(),
                        );
                        Navigator.pop(context);
                        await _loadProjects();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Project created successfully')),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isCreating = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error creating project: $e')),
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

  void _showAddMemberDialog(int projectId, String projectName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
      ),
    );

    List<dynamic> allUsers = [];
    List<dynamic> existingMembers = [];
    try {
      final results = await Future.wait([
        _apiService.getUsers(),
        _apiService.getProjectMembers(projectId),
      ]);
      allUsers = results[0];
      existingMembers = results[1];
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      return;
    }

    if (!mounted) return;
    Navigator.pop(context);

    final existingIds = existingMembers.map((m) => m['id']).toSet();
    final currentUserId = await _apiService.getUserId();
    final availableUsers = allUsers
        .where((u) => !existingIds.contains(u['id']) && u['id'] != currentUserId)
        .toList();

    int? selectedUserId;
    bool isAdding = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Member', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                projectName,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (existingMembers.isNotEmpty) ...[
                  Text('Current members', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: existingMembers.map((m) => Chip(
                      avatar: CircleAvatar(
                        backgroundColor: const Color(0xFF1565C0),
                        radius: 10,
                        child: Text(
                          m['name'].toString().substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                      label: Text(m['name'], style: const TextStyle(fontSize: 12)),
                      backgroundColor: const Color(0xFFE3F2FD),
                    )).toList(),
                  ),
                  const Divider(height: 20),
                ],
                if (availableUsers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'All registered users are already in this project.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  )
                else ...[
                  Text('Select a user to add', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: availableUsers.length,
                      itemBuilder: (context, index) {
                        final user = availableUsers[index];
                        final isSelected = selectedUserId == user['id'];
                        return InkWell(
                          onTap: () => setDialogState(() => selectedUserId = user['id']),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFE3F2FD) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFF1565C0),
                                  radius: 18,
                                  child: Text(
                                    user['name'].toString().substring(0, 1).toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(user['email'], style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                      Container(
                                        margin: const EdgeInsets.only(top: 3),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: user['role'] == 'ADMIN'
                                              ? const Color(0xFFE3F2FD)
                                              : const Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          user['role'] == 'ADMIN' ? 'Admin' : 'Member',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: user['role'] == 'ADMIN'
                                                ? const Color(0xFF1565C0)
                                                : const Color(0xFF2E7D32),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: Color(0xFF1565C0)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            if (availableUsers.isNotEmpty)
              ElevatedButton(
                onPressed: (isAdding || selectedUserId == null)
                    ? null
                    : () async {
                        setDialogState(() => isAdding = true);
                        try {
                          await _apiService.addMember(projectId, selectedUserId!);
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Member added successfully')),
                            );
                            // Refresh the projects list to show updated members
                            _loadProjects();
                          }
                        } catch (e) {
                          setDialogState(() => isAdding = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isAdding
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Add Member'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteProject(int projectId, String projectName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Project'),
        content: Text('Delete "$projectName"? All tasks in this project will also be removed.'),
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
      setState(() => _isActionLoading = true);
      await _apiService.deleteProject(projectId);
      await _loadProjects();
      setState(() => _isActionLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project deleted')),
        );
      }
    } catch (e) {
      setState(() => _isActionLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting project: $e')),
        );
      }
    }
  }

  Future<void> _showMembersDialog(int projectId, String projectName) async {
    try {
      final members = await _apiService.getProjectMembers(projectId);
      final currentUserId = await _apiService.getUserId();
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Members — $projectName', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: members.isEmpty
                ? const Center(child: Text('No members yet'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final isCurrentUser = member['id'] == currentUserId;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF1565C0),
                          child: Text(
                            member['name'].toString().substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(member['email']),
                        trailing: _userRole == 'ADMIN' && !isCurrentUser
                            ? IconButton(
                                icon: const Icon(Icons.person_remove, color: Colors.red),
                                onPressed: () => _removeMember(projectId, member['id'], member['name'], projectName),
                              )
                            : null,
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading members: $e')),
        );
      }
    }
  }

  Future<void> _removeMember(int projectId, int userId, String userName, String projectName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Member'),
        content: Text('Remove "$userName" from "$projectName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _apiService.removeMember(projectId, userId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member removed')),
        );
        // Refresh the projects list to show updated members
        _loadProjects();
        // Also show the updated members dialog
        _showMembersDialog(projectId, projectName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing member: $e')),
        );
      }
    }
  }

  Color _projectColor(int index) {
    final colors = [
      const Color(0xFF1565C0),
      const Color(0xFF6A1B9A),
      const Color(0xFF2E7D32),
      const Color(0xFFE65100),
      const Color(0xFF00838F),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1565C0),
        title: const Text('Projects', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)))
          : _projects.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: const Color(0xFF1565C0),
                  onRefresh: _loadProjects,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _projects.length,
                    itemBuilder: (context, index) => _buildProjectCard(_projects[index], index),
                  ),
                ),
      bottomNavigationBar: _buildBottomNav(context, 1),
      floatingActionButton: _userRole == 'ADMIN'
          ? FloatingActionButton.extended(
              onPressed: _showCreateProjectDialog,
              backgroundColor: const Color(0xFF1565C0),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('New Project', style: TextStyle(color: Colors.white)),
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
            decoration: const BoxDecoration(
              color: Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.folder_open_rounded, size: 60, color: Color(0xFF1565C0)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No projects yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(height: 8),
          Text(
            isAdmin
                ? 'Tap the button below to create your first project'
                : 'Ask an admin to create a project and add you',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project, int index) {
    final color = _projectColor(index);
    final isAdmin = _userRole == 'ADMIN';
    final firstLetter = project['name'].toString().substring(0, 1).toUpperCase();

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
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.25),
                  radius: 22,
                  child: Text(
                    firstLetter,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    project['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isAdmin)
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    itemBuilder: (_) => <PopupMenuEntry<dynamic>>[
                      PopupMenuItem(
                        onTap: () => _showMembersDialog(project['id'], project['name']),
                        child: const Row(children: [Icon(Icons.people_outline), SizedBox(width: 8), Text('View Members')]),
                      ),
                      PopupMenuItem(
                        onTap: () => _showAddMemberDialog(project['id'], project['name']),
                        child: const Row(children: [Icon(Icons.person_add_outlined), SizedBox(width: 8), Text('Add Member')]),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        onTap: () => _deleteProject(project['id'], project['name']),
                        child: const Row(children: [Icon(Icons.delete_outline, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))]),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (project['description'] != null && project['description'].toString().isNotEmpty) ...[
                  Text(
                    project['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF424242), fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Color(0xFF757575)),
                    const SizedBox(width: 4),
                    Text(
                      'Created by ${project['createdByName'] ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                    ),
                    if (!isAdmin) ...[
                      const Spacer(),
                      InkWell(
                        onTap: () => _showMembersDialog(project['id'], project['name']),
                        child: Row(
                          children: [
                            const Icon(Icons.people_outline, size: 14, color: Color(0xFF1565C0)),
                            const SizedBox(width: 4),
                            const Text('Members', style: TextStyle(fontSize: 12, color: Color(0xFF1565C0))),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        } else if (index == 2) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const MyTasksScreen()));
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
