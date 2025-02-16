import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sod_vendor/services/firebase.service.dart';
import 'package:sod_vendor/view_models/chat.vm.dart';
import 'package:sod_vendor/widgets/base.page.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:stacked/src/view_models/view_model_builder.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_vendor/views/pages/chat/message_card.dart';
import 'package:sod_vendor/models/user_firestore.dart';
import 'package:sod_vendor/models/chat_firestore.dart';
import 'package:sod_vendor/views/pages/chat/chat_detail.page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatViewModel>.reactive(
      viewModelBuilder: () => ChatViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          title: "Messages".tr(),
          body: vm.myConversationsStream == null
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder(
                  stream: vm.myConversationsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData ||
                        (snapshot.data as QuerySnapshot<Map<String, dynamic>>)
                            .docs
                            .isEmpty) {
                      return Center(child: Text("No conversations yet.".tr()));
                    }

                    final conversations =
                        (snapshot.data as QuerySnapshot<Map<String, dynamic>>)
                            .docs
                            .map((e) => ChatFirestore.fromJson(e.data()))
                            .toList();

                    return ListView.builder(
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final chat = conversations[index];
                        final otherUserId = chat.userIds
                            .firstWhere((id) => id != vm.currentUserId);
                        return FutureBuilder(
                          future: FirebaseService().getUserById(otherUserId),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            final user = userSnapshot.data as UserFirestore;

                            return MessageCard(
                              user: user,
                              lastMessage: chat.lastMessage,
                              lastMessageTime: chat.lastMessageTime,
                              unreadCount: 0,
                            ).px(16).py(6).onTap(() {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailPage(
                                    chatId: chat.id,
                                    currentUserId: vm.currentUserId,
                                    otherUser: user,
                                  ),
                                ),
                              );
                            });
                          },
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}
