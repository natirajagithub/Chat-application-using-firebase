import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AudioCallPage extends StatefulWidget {
  final String chatId;
  const AudioCallPage({super.key, required this.chatId});

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  String userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (currentUser != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      if (doc.exists) {
        setState(() {
          userName = doc.data()?['name'] ?? 'User';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) return const Scaffold(body: Center(child: Text('Not logged in')));

    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: 1179497554,
        appSign: '7e7a46d3f6e8fd629f66638b2d864fbad47345dac2829ceb7719268ab7cf76f0',
        userID: currentUser!.uid,
        userName: userName,
        callID: widget.chatId, // We use the unique chat room ID as the call room!
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
      ),
    );
  }
}
