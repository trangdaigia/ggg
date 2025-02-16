import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/models/user_firestore.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.user,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  final UserFirestore user;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          _buildAvatar(),
          const SizedBox(width: 12),

          // Thông tin tin nhắn
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên người dùng
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // Tin nhắn gần nhất
                Text(
                  lastMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Thời gian và số tin chưa đọc
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thời gian tin nhắn
              Text(
                _formatTime(lastMessageTime),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),

              // Hiển thị số lượng tin nhắn chưa đọc
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: unreadCount > 0 ? Colors.blue : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: unreadCount > 0
                    ? Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Xử lý avatar
  Widget _buildAvatar() {
    if (user.profileImage == null) {
      return CircleAvatar(
        radius: 25,
        backgroundColor: Colors.blueAccent,
        child: Text(
          user.name[0],
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      );
    }
    return CircleAvatar(
      radius: 25,
      backgroundImage: NetworkImage(user.profileImage!),
    );
  }

  // Định dạng thời gian
  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final Duration diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} ' + 'min'.tr();
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'Yesterday'.tr();
    } else {
      return '${time.day}/${time.month}';
    }
  }
}
