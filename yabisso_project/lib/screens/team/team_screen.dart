import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});
  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  List<Map<String, dynamic>> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _loading = true);
    final members = await DatabaseHelper.instance.getAllTeamMembers();
    setState(() {
      _members = members;
      _loading = false;
    });
  }

  Future<void> _addMember() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final roleController = TextEditingController();
    String selectedColor = '#1D9E75';

    final colors = [
      '#1D9E75',
      '#378ADD',
      '#E24B4A',
      '#F5A623',
      '#9B59B6',
      '#1ABC9C',
      '#E67E22',
      '#34495E',
    ];

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Ajouter un membre'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Nom complet',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    hintText: 'Téléphone',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleController,
                  decoration: InputDecoration(
                    hintText: 'Rôle (ex: Développeur)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Couleur',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((c) {
                    final color = _hexToColor(c);
                    final isSelected = selectedColor == c;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                Navigator.pop(ctx, {
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'role': roleController.text.trim(),
                  'color': selectedColor,
                });
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await DatabaseHelper.instance.insertTeamMember({
        'name': result['name'],
        'email': result['email']!.isEmpty ? null : result['email'],
        'phone': result['phone']!.isEmpty ? null : result['phone'],
        'role': result['role']!.isEmpty ? null : result['role'],
        'color': result['color'],
      });
      _loadMembers();
    }
  }

  Future<void> _deleteMember(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le membre'),
        content: Text('Supprimer $name de l\'équipe ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppColors.primaryRed),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseHelper.instance.deleteTeamMember(id);
      _loadMembers();
    }
  }

  static Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Équipe')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aucun membre dans l\'équipe',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ajoutez des membres pour collaborer',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMembers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _members.length,
                    itemBuilder: (context, i) => _buildMemberCard(_members[i]),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMember,
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    final name = member['name'] as String;
    final email = member['email'] as String?;
    final phone = member['phone'] as String?;
    final role = member['role'] as String?;
    final colorStr = member['color'] as String? ?? '#1D9E75';
    final color = _hexToColor(colorStr);

    final parts = name.split(' ');
    String initials;
    if (parts.length >= 2) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      initials = name.substring(0, name.length.clamp(0, 2)).toUpperCase();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (role != null && role.isNotEmpty)
                  Text(
                    role,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                if (email != null && email.isNotEmpty)
                  Text(
                    email,
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                if (phone != null && phone.isNotEmpty)
                  Text(
                    phone,
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.primaryRed,
              size: 20,
            ),
            onPressed: () => _deleteMember(member['id'] as int, name),
          ),
        ],
      ),
    );
  }
}
