import 'package:flutter/src/widgets/framework.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatViewModel extends MyBaseViewModel {
  ChatViewModel(this.context);
  BuildContext context;
  late final int currentUserId;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>>? myConversationsStream;

  initialise() async {
    final currentUser = await AuthServices.getCurrentUser();
    currentUserId = currentUser.id;
    myConversationsStream = firestore
        .collection('chats')
        .where('userIds', arrayContains: currentUserId)
        .snapshots();

    notifyListeners();
  }
}
