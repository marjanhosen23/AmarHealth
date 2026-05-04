import 'package:flutter/material.dart';
import 'package:hospital_app/common/manage_account.dart';
import 'package:hospital_app/theme/app_colors.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  double fontSize = 14;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppColors.primary,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// SETTINGS CARD
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card_primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  /// Manage Account
                  ListTile(
                    title: const Text("Manage Account"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      setState(() {
                        Navigator.push(context, MaterialPageRoute(builder: (_)=> ManageAccount()));
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// DEVELOPERS
            const Text(
              "Developers",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/profile1.png'),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Marjan Hosen Oni",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "UI Designer and App Developer\nExperienced in Flutter",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}