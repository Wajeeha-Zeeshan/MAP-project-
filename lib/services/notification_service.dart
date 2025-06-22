import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final CollectionReference _notificationsCollection = FirebaseFirestore
      .instance
      .collection('notifications');

  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    final snapshot =
        await _notificationsCollection
            .where('receiverId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .get();

    return snapshot.docs
        .map(
          (doc) => NotificationModel.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({'isRead': true});
  }

  Future<void> sendNotification({
    required String senderId,
    required String receiverId,
    required String message,
    required String type,
  }) async {
    await _notificationsCollection.add({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'type': type,
      'timestamp': DateTime.now(),
      'isRead': false,
    });
  }
}
