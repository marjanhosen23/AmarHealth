import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hospital_app/admin/auth/admin_login.dart';
import 'package:hospital_app/theme/app_colors.dart';

class ManageAccount extends StatelessWidget {
  const ManageAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          "Manage Account",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card_small,
            borderRadius: BorderRadius.circular(18),
          ),
          child: ListTile(
            title: const Text(
              "Delete your account",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              _showDeleteDialog(context);
            },
          ),
        ),
      ),
    );
  }

  /// Delete confirmation dialog
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "Your account will be deleted after 30 days.\nYou can still login within this period.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _softDeleteHospital(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Soft delete function (30 days)
  Future<void> _softDeleteHospital(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hospitalKey = prefs.getString('currentHospital');

      if (hospitalKey == null) return;

      /// mark as deleted
      await FirebaseFirestore.instance
          .collection('hospitals')
          .doc(hospitalKey)
          .update({
        'deleted': true,
        'deleteTime': FieldValue.serverTimestamp(),
      });

      /// remove local session
      await prefs.remove('currentHospital');

      /// redirect to login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminLogin()),
            (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account scheduled for deletion (30 days)'),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }
}