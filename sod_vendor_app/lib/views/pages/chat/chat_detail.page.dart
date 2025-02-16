import 'package:flutter/material.dart';
import 'package:sod_vendor/models/user_firestore.dart';
import 'package:sod_vendor/models/message_firestore.dart';
import 'package:sod_vendor/view_models/chat_detail.vm.dart';
import 'package:stacked/src/view_models/view_model_builder.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_vendor/constants/app_colors.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final int currentUserId;
  final UserFirestore otherUser;

  const ChatDetailPage({
    Key? key,
    required this.chatId,
    required this.currentUserId,
    required this.otherUser,
  }) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  late final MAX_WIDTH;
  late final color;

  @override
  initState() {
    super.initState();
    color = AppColor.primaryColor;
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    MAX_WIDTH = MediaQuery.of(context).size.width * 0.7;
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatDetailViewModel>.reactive(
      viewModelBuilder: () => ChatDetailViewModel(
        chatId: widget.chatId,
        currentUserId: widget.currentUserId,
        otherUser: widget.otherUser,
        context: context,
      ),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text(widget.otherUser.name).centered().expand(),
                if (widget.otherUser.profileImage != null)
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage(widget.otherUser.profileImage!),
                    radius: 20,
                  ),
              ],
            ),
          ),
          backgroundColor: Colors.grey.shade100,
          body: Column(
            children: [
              Expanded(
                child: vm.messages.isEmpty
                    ? Center(child: Text("No messages yet.".tr()))
                    : ListView.builder(
                        reverse: true,
                        controller: vm.scrollController,
                        itemCount:
                            vm.messages.length + 1, // Thêm 1 để hiện loader
                        itemBuilder: (context, index) {
                          if (index == vm.messages.length) {
                            return vm.isLoadingMore
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : const SizedBox.shrink();
                          }

                          return _buildMessageItem(
                              vm.isSending, vm.messages, index);
                        },
                      ),
              ),
              _buildMessageInput(vm),
            ],
          ),
        );
      },
    );
  }

  /// Widget hiển thị một tin nhắn đơn lẻ
  Widget _buildMessageItem(
      bool isSending, List<MessageFirestore> messages, int index) {
    final message = messages[index];
    final isMe = message.fromId == widget.currentUserId;
    // Show user info if this is the last message or the previous message is from the current user
    final showUserInfo = (!isMe && index == 0) ||
        (!isMe && messages[index - 1].fromId == widget.currentUserId);
    // padding beetwen my messages and other user messages
    final isPadding =
        index == 0 || messages[index - 1].fromId != message.fromId;

    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (message.type == MessageTypes.text)
          _buildMessageBubble(message, isMe)
        else if (message.type == MessageTypes.image)
          _buildImageBubble(message, isMe)
        else if (message.type == MessageTypes.location)
          _buildLocationBubble(message, isMe)
        else
          _buildMessageBubble(message, isMe),
        if (showUserInfo) _buildUserInfoRow(message),
        if (isSending && index == 0)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Sending...'.tr(),
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ).px(16),
          ),
        if (isPadding) const SizedBox(height: 8),
      ],
    );
  }

  /// Bubble tin nhắn
  Widget _buildMessageBubble(MessageFirestore message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? color : Colors.white,
          borderRadius: BorderRadius.only(
            topRight: isMe ? Radius.zero : Radius.circular(30),
            topLeft: isMe ? Radius.circular(30) : Radius.zero,
            bottomRight: isMe ? Radius.zero : Radius.circular(30),
            bottomLeft: isMe ? Radius.circular(30) : Radius.zero,
          ),
        ),
        child: Text(
          message.message,
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ).px(12).py(6),
      ).constrainedBox(
        BoxConstraints(maxWidth: MAX_WIDTH),
      ),
    );
  }

  /// Bubble hình ảnh
  Widget _buildImageBubble(MessageFirestore message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topRight: isMe ? Radius.zero : Radius.circular(30),
            topLeft: isMe ? Radius.circular(30) : Radius.zero,
            bottomRight: isMe ? Radius.zero : Radius.circular(30),
            bottomLeft: isMe ? Radius.circular(30) : Radius.zero,
          ),
          child: Image.network(message.message).p(0),
        ),
      ).constrainedBox(
        BoxConstraints(maxWidth: MAX_WIDTH),
      ),
    );
  }

  /// Bubble vị trí
  Widget _buildLocationBubble(MessageFirestore message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? color : Colors.white,
          borderRadius: BorderRadius.only(
            topRight: isMe ? Radius.zero : Radius.circular(30),
            topLeft: isMe ? Radius.circular(30) : Radius.zero,
            bottomRight: isMe ? Radius.zero : Radius.circular(30),
            bottomLeft: isMe ? Radius.circular(30) : Radius.zero,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMe
                  ? 'Location:'.tr()
                  : '${widget.otherUser.name} ' + 'sent a location:'.tr(),
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Click to view location'.tr(),
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ).px(12).py(6),
      )
          .constrainedBox(
            BoxConstraints(maxWidth: MAX_WIDTH),
          )
          .onTap(
            () => launchUrl(Uri.parse(message.message)),
          ),
    );
  }

  /// Hiển thị thông tin người gửi và thời gian
  Widget _buildUserInfoRow(MessageFirestore message) {
    return Row(
      children: [
        if (widget.otherUser.profileImage != null)
          CircleAvatar(
            backgroundImage: NetworkImage(widget.otherUser.profileImage!),
            radius: 20,
          ).p(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherUser.name,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
            Text(
              DateFormat('HH:mm').format(message.sentAt!),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    ).pOnly(bottom: 5);
  }

  /// Khung nhập tin nhắn
  Widget _buildMessageInput(ChatDetailViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      height: 55,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.image, color: Colors.white),
            onPressed: () => vm.onSendImageClick(),
          ),
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.white),
            onPressed: () => vm.onSendLocationClick(),
          ),
          Expanded(
            child: TextField(
              controller: vm.messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Send message...".tr(),
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  vm.setTyping(true);
                } else {
                  vm.setTyping(false);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () => vm.onSendClick(),
          ),
        ],
      ).p(8),
    ).p(12);
  }
}
