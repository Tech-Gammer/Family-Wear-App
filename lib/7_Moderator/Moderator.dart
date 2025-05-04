import 'package:flutter/material.dart';

import '../5_Admin/AdminHomePages/Order_Managment/adminOrderList.dart';
import '../5_Admin/AdminHomePages/Order_Managment/ordercancellation.dart';
import '../6_Customer/HomeScreen.dart';

class ModeratorPanel extends StatelessWidget {
  const ModeratorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderator Panel'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.05,
          vertical: height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPanelButton(
              context,
              icon: Icons.supervised_user_circle,
              title: "Manage Orders",
              color: Colors.blueAccent,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AdminOrdersScreen()));
                },
            ),
            SizedBox(height: height * 0.02),
            _buildPanelButton(
              context,
              icon: Icons.report,
              title: "View Cancellation Requests",
              color: Colors.redAccent,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AdminCancellationRequestsScreen()));
                },
            ),
            SizedBox(height: height * 0.02),
            _buildPanelButton(
              context,
              icon: Icons.settings,
              title: "Go to customer side",
              color: Colors.green,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Color color,
        required VoidCallback onTap,
      }) {
    final width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        color: color,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: width * 0.05,
            horizontal: width * 0.04,
          ),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
