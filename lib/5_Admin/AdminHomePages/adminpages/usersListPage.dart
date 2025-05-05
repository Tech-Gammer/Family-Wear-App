
import 'dart:convert';
import 'package:family_wear_app/5_Admin/AdminHomePages/adminpages/usersListProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../2_Assets/Colors/Colors_Scheme.dart';

class AdminsPage extends StatelessWidget {
  const AdminsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AllUserProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Admins & Moderators"),
            centerTitle: true,
          ),
          body: Container(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _buildSearchField(provider),
                  const SizedBox(height: 16),
                  _buildRoleChips(provider),
                  const SizedBox(height: 16),
                  Expanded(child: _buildUserList(provider)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchField(AllUserProvider provider) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(4),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          //fillColor: Colors.white,
          hintText: 'Search by name, email, or ID',
          prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: provider.setSearchQuery,
      ),
    );
  }

  Widget _buildRoleChips(AllUserProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All', 'Admin', 'Moderator','Users'].map((role) {
          final isSelected = provider.selectedRole == role;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                role,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primaryColor,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primaryColor,
              //backgroundColor: Colors.white,
              onSelected: (_) => provider.setSelectedRole(role),
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? Colors.transparent : AppColors.primaryColor.withOpacity(0.3),
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getRoleColor(int role) {
    switch (role) {
      case 0:
        return AppColors.primaryColor;
      case 1:
        return Colors.green.shade600;
      case 2:
        return Colors.teal.shade600;
      default:
        return Colors.grey;
    }
  }

  Widget _buildUserList(AllUserProvider provider) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        ),
      );
    }

    if (provider.filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppColors.primaryColor.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text("No users found", style: TextStyle(color: AppColors.primaryColor)),
            if (provider.selectedRole != 'All')
              TextButton(
                onPressed: provider.clearFilters,
                child: Text("Clear filters", style: TextStyle(color: AppColors.primaryColor)),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.filteredUsers.length,
      itemBuilder: (context, index) {
        final user = provider.filteredUsers[index];
        return _buildUserTile(user,context);
      },
    );
  }

  Widget _buildUserTile(Map user, BuildContext context) {
    final (roleColor, roleLabel) = switch (user['role']) {
      0 => (AppColors.primaryColor, "Admin"),
      1 => (Colors.green.shade600, "User"),
      2 => (Colors.teal.shade600, "Moderator"),
      _ => (Colors.grey.shade600, "Unknown Role"),
    };

    final roles = {
      0: 'Admin',
      1: 'User',
      2: 'Moderator',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          decoration: BoxDecoration(
            //color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: Text(user['user_name'], style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['email']),
                if (user.containsKey('user_id'))
                  Text("ID: ${user['user_id']}", style: const TextStyle(fontSize: 12)),
              ],
            ),
            trailing: DropdownButton<int>(
              value: user['role'],
              icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
              underline: const SizedBox(),
              items: roles.entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      color: _getRoleColor(entry.key),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (int? newValue) async {
                if (newValue != null && newValue != user['role']) {
                  try {
                    final provider = Provider.of<AllUserProvider>(
                      context,
                      listen: false,
                    );
                    await provider.updateUserRole(user['user_id'].toString(), newValue);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Role updated to ${roles[newValue]}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update role: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}