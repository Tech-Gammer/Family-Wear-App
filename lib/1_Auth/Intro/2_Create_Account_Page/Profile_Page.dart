// Second
import 'package:family_wear_app/6_Customer/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../2_Assets/Colors/Colors_Scheme.dart';
import '../Intro_Providers/Profile_Provider.dart'; // Ensure this import path is correct

class ProfilePage extends StatefulWidget {
  final int userId; // Receive user_id from previous page
  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Center(
                  child: Text(
                    "Complete Your Profile",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.065,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.002),

                // Subtitle
                Center(
                  child: Text(
                    "Don't worry, only you can see your personal \ndata. No one else will be able to see it.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),

                // Profile Image Section
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: profileProvider.profileImageFile != null ? FileImage(profileProvider.profileImageFile!) : profileProvider.profileImageUrl != null ? NetworkImage(profileProvider.profileImageUrl!) : null,
                        backgroundColor: Colors.grey[300],
                        child: profileProvider.profileImageFile == null && profileProvider.profileImageUrl == null ? const Icon(Icons.person, size: 70, color: Colors.red) : null,
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: InkWell(
                          onTap: () async {
                            await profileProvider.pickImage();
                            if (profileProvider.profileImageFile != null) {
                              await profileProvider.uploadImage();
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 15,
                            child: const Icon(Icons.edit, size: 15, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Name TextField
                _buildInputField(
                  label: "Name",
                  hint: "Ex. John Doe",
                  controller: profileProvider.nameController,
                  validator: (value) => value!.isEmpty ? "Please enter your name" : null,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),

                // Phone Number TextField
                _buildInputField(
                  label: "Phone Number",
                  hint: "Ex. 03001234567",
                  controller: profileProvider.phoneNumberController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your phone number";
                    }

                    final localPattern = RegExp(r'^03[0-9]{9}$');            // e.g. 03216455926
                    final intlPattern = RegExp(r'^\+923[0-9]{9}$');          // e.g. +923416455926

                    if (!localPattern.hasMatch(value) && !intlPattern.hasMatch(value)) {
                      return "Enter a valid phone number (e.g. 0321XXXXXXX or +92321XXXXXXX)";
                    }

                    return null;
                  },

                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),

                // Gender Dropdown
                _buildDropdownField(
                  label: "Gender",
                  hint: "Select Gender",
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  value: profileProvider.gender,
                  items: ["Male", "Female", "Other"],
                  onChanged: (value) {
                    profileProvider.setGender(value!);
                  },
                ),

                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          await profileProvider.submitProfile(context, widget.userId);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated Successfully!")),);
                          //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(),));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e")),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Complete Profile",
                        style: TextStyle(
                          color: isDarkTheme ? AppColors.darkTextColor : AppColors.lightTextColor,
                          fontSize: screenWidth * 0.05,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Input Field
  Widget _buildInputField({
    required double screenWidth,
    required double screenHeight,
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: screenHeight * 0.005),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  // Reusable Dropdown Field
  Widget _buildDropdownField({
    required String label,
    required String hint,
    required double screenWidth,
    required double screenHeight,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: screenHeight * 0.008),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            hint: Text(hint),
            items: items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            )).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please select your gender";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
