import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messenger_chat/components/cloudinary_uploader.dart';
import 'package:messenger_chat/components/message_bubble.dart';
import 'package:messenger_chat/services/notification_services.dart';
import 'package:messenger_chat/services/get_server_key.dart';
import 'package:messenger_chat/services/gemini_service.dart';
import 'package:messenger_chat/services/profile_picture_service.dart';

class ChartScreen extends StatefulWidget {
  final String chatId;
  final String reciverId;
  final String reciverEmail;

  const ChartScreen({
    super.key,
    required this.chatId,
    required this.reciverId,
    required this.reciverEmail,
  });

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  TextEditingController messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isGeminiTyping = false;

  // Chat management methods
  void _showChatOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Clear Chat Option
              ListTile(
                leading: const Icon(Icons.clear_all, color: Color(0xFF8B5CF6)),
                title: Text(
                  'Clear Chat',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showClearChatDialog();
                },
              ),

              // Delete Chat Option
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: Text(
                  'Delete Chat',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteChatDialog();
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text(
          'This will clear all messages from this chat. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearChat();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text(
          'This will delete the entire conversation. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteChat();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearChat() async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Clearing chat...'),
          backgroundColor: const Color(0xFF8B5CF6),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );

      // Get all messages in the chat
      final messagesQuery = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .get();

      // Delete all messages
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in messagesQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Chat cleared successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to clear chat'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteChat() async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Deleting chat...'),
          backgroundColor: const Color(0xFF8B5CF6),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );

      // Get all messages in the chat
      final messagesQuery = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .get();

      // Delete all messages
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in messagesQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Navigate back to users screen
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Chat deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete chat'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }
    }
  }

  // Individual message deletion
  void _showMessageDeleteOptions(String messageId, bool isMyMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Choose how you want to delete this message:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMessageForMe(messageId);
            },
            child: const Text(
              'Delete for Me',
              style: TextStyle(color: Colors.orange),
            ),
          ),
          if (isMyMessage) // Only show "Delete for Everyone" for own messages
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteMessageForEveryone(messageId);
              },
              child: const Text(
                'Delete for Everyone',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _deleteMessageForMe(String messageId) async {
    try {
      // For "delete for me", we can add a field to mark it as deleted for this user
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(messageId)
          .update({
            'deletedFor': FieldValue.arrayUnion([currentUser!.uid]),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Message deleted for you'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete message'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteMessageForEveryone(String messageId) async {
    try {
      // For "delete for everyone", we update the message content
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(messageId)
          .update({
            'text': 'This message was deleted',
            'deletedForEveryone': true,
            'mediaUrl': FieldValue.delete(),
            'type': 'deleted',
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Message deleted for everyone'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete message'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }
    }
  }

  void sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final isGeminiChat = widget.reciverId == 'gemini_ai';

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
          'text': messageController.text.trim(),
          'senderId': currentUser!.uid,
          'receiverId': widget.reciverId,
          'timestamp': Timestamp.now(),
          'isSeen': false,
        });
    messageController.clear();

    if (isGeminiChat) {
      setState(() {
        isGeminiTyping = true; // Start typing indicator
      });

      final aiResponse = await GeminiService.getGimniResponse(text);

      // Add Gemini's message
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
            'text': aiResponse,
            'senderId': 'gemini_ai',
            'receiverId': currentUser!.uid,
            'timestamp': Timestamp.now(),
          });
      setState(() {
        isGeminiTyping = false; // Stop typing indicator
      });
    } else {
      //Send push notification to real user
      await _sendPushNotification(text);
    }
  }

  final CloudinaryUploader uploader = CloudinaryUploader();

  String _getCloudinaryThumbnailUrl(String videoUrl) {
    final uri = Uri.parse(videoUrl);
    final parts = uri.pathSegments;

    final cloudName = parts[0]; // e.g., "res.cloudinary.com/yourname"
    final basePathIndex = parts.indexOf("upload");
    final publicId = parts
        .sublist(basePathIndex + 1)
        .join('/')
        .replaceAll('.mp4', '')
        .replaceAll('.mov', '');

    return "https://res.cloudinary.com/$cloudName/video/upload/so_2,w_400,h_300,c_fill/$publicId.jpg";
  }

  void _onImageSend() async {
    //Pick file only (without upload yet)
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi'],
    );

    if (result == null || result.files.isEmpty) return;

    final filePath = result.files.first.path!;
    final isVideo =
        filePath.endsWith('.mp4') ||
        filePath.endsWith('.mov') ||
        filePath.endsWith('.avi');
    final messageType = isVideo ? 'video' : 'image';

    //Show sending placeholder message first
    final docRef = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
          'senderId': currentUser!.uid,
          'receiverId': widget.reciverId,
          'timestamp': Timestamp.now(),
          'isSeen': false,
          'type': 'uploading',
        });

    try {
      //Upload the file now
      final mediaUrl = await uploader.uploadToCloudinary(
        File(filePath),
        isVideo ? 'video' : 'image',
      );

      if (mediaUrl != null) {
        // STEP 4: Optional – Cloudinary thumbnail for video
        String? thumbnailUrl;
        if (isVideo) {
          thumbnailUrl = _getCloudinaryThumbnailUrl(mediaUrl);
        }

        // Update placeholder message with real data
        await docRef.update({
          'mediaUrl': mediaUrl,
          'type': messageType,
          if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        });

        // Push notification
        await _sendPushNotification("Sent a ${isVideo ? 'video' : 'photo'}");
      } else {
        await docRef.delete(); // Clean up failed upload
      }
    } catch (e) {
      // print('Upload failed: $e');
      await docRef.delete(); // Clean up failed upload
    }
  }

  Future<void> _sendPushNotification(String messageBody) async {
    try {
      // 1. Get receiver's FCM token from Firestore
      final receiverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.reciverId)
          .get();

      final receiverToken = receiverDoc['fcmToken'];

      if (receiverToken != null && receiverToken.isNotEmpty) {
        // 2. Get access token for HTTP v1 API
        final accessToken = await GetServerKey().getServerKeyToken();

        // 3. Send the notification
        await NotificationService.sendPushNotification(
          token: receiverToken,
          title: currentUser!.email!.replaceAll('@gmail.com', ''),
          body: messageBody,
          accessToken: accessToken,
        );
      }
    } catch (e) {
      print("Error sending push notification: $e");
    }
  }

  void _markMessagesAsSeen() async {
    final query = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUser!.uid)
        .where('isSeen', isEqualTo: false)
        .get();

    for (var doc in query.docs) {
      doc.reference.update({'isSeen': true});
    }
  }

  @override
  void initState() {
    super.initState();
    _markMessagesAsSeen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F23),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Back Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // User Info
                    Expanded(
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.reciverId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          String? profilePicture;
                          if (snapshot.hasData && snapshot.data!.exists) {
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>?;
                            profilePicture = data?['profilePicture'];
                          }

                          return Row(
                            children: [
                              // Profile Picture with glow
                              Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF8B5CF6,
                                          ).withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: widget.reciverId == 'gemini_ai'
                                        ? Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            child: CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.white,
                                              backgroundImage: const AssetImage(
                                                'images/meta.png',
                                              ),
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            child:
                                                ProfilePictureService.buildProfileAvatar(
                                                  base64Image: profilePicture,
                                                  fallbackText: widget
                                                      .reciverEmail[0]
                                                      .toUpperCase(),
                                                  radius: 20,
                                                ),
                                          ),
                                  ),
                                  // Online indicator
                                  if (widget.reciverId != 'gemini_ai')
                                    Positioned(
                                      bottom: 2,
                                      right: 2,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(width: 12),

                              // Name and Status
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.reciverEmail.split('@')[0],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      widget.reciverId == 'gemini_ai'
                                          ? 'AI Assistant'
                                          : 'Online',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // More options button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: _showChatOptionsMenu,
                      ),
                    ),
                  ],
                ),
              ),

              // Chat Messages Container
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Messages
                      Expanded(
                        child: MessageList(
                          widget: widget,
                          isGeminiTyping: isGeminiTyping,
                          onMessageLongPress: _showMessageDeleteOptions,
                        ),
                      ),

                      // Message Input
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Attachment button (only for non-AI chats)
                            if (widget.reciverId != 'gemini_ai')
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF8B5CF6),
                                      Color(0xFF7C3AED),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF8B5CF6,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: _onImageSend,
                                  icon: const Icon(
                                    Icons.attach_file,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),

                            if (widget.reciverId != 'gemini_ai')
                              const SizedBox(width: 12),

                            // Message Input Field
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: messageController,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Type a message...",
                                    hintStyle: TextStyle(
                                      color: Colors.grey.withValues(alpha: 0.6),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                  maxLines: null,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Send Button
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8B5CF6),
                                    Color(0xFF7C3AED),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF8B5CF6,
                                    ).withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25),
                                  onTap: sendMessage,
                                  child: const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageList extends StatelessWidget {
  const MessageList({
    super.key,
    required this.widget,
    required this.isGeminiTyping,
    required this.onMessageLongPress,
  });

  final ChartScreen widget;
  final bool isGeminiTyping;
  final Function(String messageId, bool isMyMessage) onMessageLongPress;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: Color(0xFF419cd7)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No message yet'));
        }

        final allMessages = snapshot.data!.docs;
        final currentUserId = FirebaseAuth.instance.currentUser!.uid;

        // Filter out messages deleted for current user
        final messages = allMessages.where((message) {
          final messageData = message.data() as Map<String, dynamic>;
          final deletedFor = messageData['deletedFor'] as List<dynamic>?;
          return deletedFor == null || !deletedFor.contains(currentUserId);
        }).toList();

        return ListView.builder(
          reverse: true,
          itemCount: isGeminiTyping && widget.reciverId == 'gemini_ai'
              ? messages.length + 1
              : messages.length,
          itemBuilder: (context, index) {
            // If it's the first item and Gemini is typing, show typing bubble
            if (isGeminiTyping &&
                widget.reciverId == 'gemini_ai' &&
                index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Gemini is typing...',
                      style: TextStyle(
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              );
            }
            //  Adjust index if Gemini is typing
            final messageIndex =
                isGeminiTyping && widget.reciverId == 'gemini_ai'
                ? index - 1
                : index;
            final message = messages[messageIndex];

            return MessageBubble(
              key: ValueKey(message.id),
              text: (message.data() as Map<String, dynamic>).containsKey('text')
                  ? message['text']
                  : '',
              mediaUrl:
                  (message.data() as Map<String, dynamic>).containsKey(
                    'mediaUrl',
                  )
                  ? message['mediaUrl']
                  : null,
              isMe:
                  message['senderId'] == FirebaseAuth.instance.currentUser!.uid,
              type: (message.data() as Map<String, dynamic>).containsKey('type')
                  ? message['type']
                  : 'text',
              thumbnailPath:
                  (message.data() as Map<String, dynamic>).containsKey(
                    'thumbnailUrl',
                  )
                  ? message['thumbnailUrl']
                  : null,
              messageId: message.id,
              onLongPress: onMessageLongPress,
            );
          },
        );
      },
    );
  }
}
