import 'dart:convert';

import 'package:family_wear_app/5_Admin/AdminHomePages/adminpages/usersListProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.teal.shade600],
                ),
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
      borderRadius: BorderRadius.circular(12),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search by name, email, or ID',
          prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
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
                  color: isSelected ? Colors.white : Colors.blue.shade700,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.blue.shade700,
              backgroundColor: Colors.white,
              onSelected: (_) => provider.setSelectedRole(role),
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.blue.shade200,
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
        return Colors.blue.shade700;
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
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
        ),
      );
    }

    if (provider.filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.blue.shade200),
            const SizedBox(height: 16),
            Text("No users found", style: TextStyle(color: Colors.blue.shade700)),
            if (provider.selectedRole != 'All')
              TextButton(
                onPressed: provider.clearFilters,
                child: Text("Clear filters", style: TextStyle(color: Colors.blue.shade700)),
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
    // final roleColor = user['role'] == 0 ? Colors.blue.shade700 : Colors.teal.shade600;
    // final roleLabel = user['role'] == 0 ? "Admin" : "Moderator";
    //print('User Image: ${user['user_image']}');
    // Determine role color and label
    final (roleColor, roleLabel) = switch (user['role']) {
      0 => (Colors.blue.shade700, "Admin"),
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            // leading: user['user_image'] != null && user['user_image'] != ''
            //     ? CircleAvatar(
            //   radius: 30,
            //   backgroundImage: NetworkImage(
            //     utf8.decode(base64Decode(user['user_image'])),
            //   ),
            //
            //   //backgroundImage: NetworkImage(user['user_image']),
            // )
            //     : CircleAvatar(
            //   radius: 30,
            //   child: Icon(Icons.person, size: 30, color: Colors.blue.shade700),
            // ),


            title: Text(user['user_name'], style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['email']),
                if (user.containsKey('user_id'))
                  Text("ID: ${user['user_id']}", style: const TextStyle(fontSize: 12)),
              ],
            ),
            // trailing: Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            //   decoration: BoxDecoration(
            //     color: roleColor.withOpacity(0.1),
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Text(
            //     roleLabel,
            //     style: TextStyle(
            //       color: roleColor,
            //       fontWeight: FontWeight.bold,
            //       fontSize: 12,
            //     ),
            //   ),
            // ),
            trailing: DropdownButton<int>(
              value: user['role'],
              icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
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