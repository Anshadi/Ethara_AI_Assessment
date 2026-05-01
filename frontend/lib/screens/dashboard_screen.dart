import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'projects_screen.dart';
import 'my_tasks_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _apiService = ApiService();
  String? _userName;
  String? _userRole;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadUserInfo();
    await _loadDashboard();
  }

  Future<void> _loadUserInfo() async {
    final name = await _apiService.getName();
    final role = await _apiService.getRole();
    setState(() {
      _userName = name;
      _userRole = role;
    });
  }

  Future<void> _loadDashboard() async {
    try {
      final data = await _apiService.getDashboard();
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _apiService.clearAuthData();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1565C0),
        title: const Text(
          'TaskFlow',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)))
          : RefreshIndicator(
              color: const Color(0xFF1565C0),
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Overview',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatsGrid(),
                          const SizedBox(height: 16),
                          _buildOverdueCard(),
                          const SizedBox(height: 32),
                          const Text(
                            'Quick Access',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildQuickAccessRow(context),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNav(context, 0),
    );
  }

  Widget _buildHeader() {
    final isAdmin = _userRole == 'ADMIN';
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1565C0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.25),
            child: Text(
              _getInitials(_userName ?? 'U'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${_userName ?? 'User'}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAdmin ? Icons.admin_panel_settings : Icons.person,
                        color: Colors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isAdmin ? 'Administrator' : 'Team Member',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {
        'label': 'Total',
        'value': _dashboardData?['total'] ?? 0,
        'icon': Icons.assignment_outlined,
        'color': const Color(0xFF1565C0),
        'bg': const Color(0xFFE3F2FD),
      },
      {
        'label': 'To Do',
        'value': _dashboardData?['todo'] ?? 0,
        'icon': Icons.radio_button_unchecked,
        'color': const Color(0xFFE65100),
        'bg': const Color(0xFFFFF3E0),
      },
      {
        'label': 'In Progress',
        'value': _dashboardData?['inProgress'] ?? 0,
        'icon': Icons.sync_rounded,
        'color': const Color(0xFF6A1B9A),
        'bg': const Color(0xFFF3E5F5),
      },
      {
        'label': 'Completed',
        'value': _dashboardData?['done'] ?? 0,
        'icon': Icons.check_circle_outline,
        'color': const Color(0xFF2E7D32),
        'bg': const Color(0xFFE8F5E9),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.6,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final s = stats[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: s['bg'] as Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(s['icon'] as IconData, color: s['color'] as Color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s['value'].toString(),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: s['color'] as Color,
                      ),
                    ),
                    Text(
                      s['label'] as String,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverdueCard() {
    final overdue = _dashboardData?['overdue'] ?? 0;
    final hasOverdue = overdue > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasOverdue
              ? [const Color(0xFFC62828), const Color(0xFFEF5350)]
              : [const Color(0xFF2E7D32), const Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (hasOverdue ? Colors.red : Colors.green).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            hasOverdue ? Icons.warning_amber_rounded : Icons.verified_rounded,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                overdue.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                hasOverdue ? 'Overdue Tasks — Act now!' : 'All tasks on track',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickCard(
            context,
            icon: Icons.folder_open_rounded,
            label: 'Projects',
            color: const Color(0xFF1565C0),
            bg: const Color(0xFFE3F2FD),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProjectsScreen()),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildQuickCard(
            context,
            icon: Icons.task_alt_rounded,
            label: 'My Tasks',
            color: const Color(0xFF2E7D32),
            bg: const Color(0xFFE8F5E9),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyTasksScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
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
        if (index == 1) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const ProjectsScreen()));
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
