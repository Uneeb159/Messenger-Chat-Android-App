import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePictureService {
  static const int maxSizeBytes = 1024 * 1024; // 1MB limit

  static Future<String?> pickAndUploadImage(
    BuildContext context, {
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Read image as bytes
      final Uint8List imageBytes = await image.readAsBytes();

      // Check file size
      if (imageBytes.length > maxSizeBytes) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Image size must be less than 1MB. Current size: ${(imageBytes.length / 1024 / 1024).toStringAsFixed(2)}MB',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }

      // Convert to base64
      final String base64Image = base64Encode(imageBytes);

      // Save to Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'profilePicture': base64Image,
              'profilePictureUpdated': Timestamp.now(),
            });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Color(0xFF8B5CF6),
            ),
          );
        }

        return base64Image;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return null;
  }

  static Future<bool> deleteProfilePicture(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'profilePicture': FieldValue.delete(),
              'profilePictureUpdated': Timestamp.now(),
            });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture deleted successfully!'),
              backgroundColor: Color(0xFF8B5CF6),
            ),
          );
        }

        return true;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return false;
  }

  static Widget buildProfileAvatar({
    required String? base64Image,
    required String fallbackText,
    required double radius,
    Color backgroundColor = const Color(0xFF8B5CF6),
  }) {
    if (base64Image != null && base64Image.isNotEmpty) {
      try {
        final Uint8List imageBytes = base64Decode(base64Image);
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: radius - 2,
            backgroundImage: MemoryImage(imageBytes),
            backgroundColor: backgroundColor,
          ),
        );
      } catch (e) {
        // If base64 decoding fails, show fallback
      }
    }

    // Fallback avatar with text
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: radius - 2,
        backgroundColor: backgroundColor,
        child: Text(
          fallbackText,
          style: TextStyle(
            fontSize: radius * 0.6,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
