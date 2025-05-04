import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> helpTopics = [
      {
        'question': 'How do I reset my password?',
        'answer': 'Go to Login > Forgot Password and follow the instructions.'
      },
      {
        'question': 'How can I contact customer support?',
        'answer': 'You can email us at umairmughalflh@example.com or use the contact form in the app.'
      },
      {
        'question': 'How do I update my profile?',
        'answer': 'Go to your profile page and tap the Arrow button.'
      },
      {
        'question': 'Why is my account locked?',
        'answer': 'Your account may be locked after multiple failed login attempts. Contact support to unlock it.'
      },
      {
        'question': 'How do I delete my account?',
        'answer': 'Go to Settings > Account > Delete Account. This action is permanent.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
      ),
      body: ListView.builder(
        itemCount: helpTopics.length,
        itemBuilder: (context, index) {
          final topic = helpTopics[index];
          return ExpansionTile(
            title: Text(topic['question']!),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(topic['answer']!),
              )
            ],
          );
        },
      ),
    );
  }
}
