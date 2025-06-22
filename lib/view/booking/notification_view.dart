import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../viewmodels/notification_viewmodel.dart';

class NotificationView extends StatefulWidget {
  final String userId;

  const NotificationView({super.key, required this.userId});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  late NotificationViewModel _notificationViewModel;

  @override
  void initState() {
    super.initState();
    _notificationViewModel = NotificationViewModel();
    _notificationViewModel.loadNotifications(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NotificationViewModel>.value(
      value: _notificationViewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          backgroundColor: const Color(0xFF4facfe),
        ),
        backgroundColor: Colors.white,
        body: Consumer<NotificationViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error != null) {
              return Center(
                child: Text(
                  viewModel.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (viewModel.notifications.isEmpty) {
              return const Center(child: Text('No notifications yet.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.notifications.length,
              itemBuilder: (context, index) {
                final notification = viewModel.notifications[index];
                final formattedTime = DateFormat.yMd().add_jm().format(
                  notification.timestamp,
                );

                return Card(
                  color:
                      notification.isRead
                          ? Colors.white
                          : const Color(0xFFE3F2FD),
                  child: ListTile(
                    leading: Icon(
                      _getNotificationIcon(notification.type),
                      color: notification.isRead ? Colors.grey : Colors.blue,
                    ),
                    title: Text(notification.message),
                    subtitle: Text(formattedTime),
                    onTap: () {
                      if (!notification.isRead) {
                        viewModel.markAsRead(notification.id);
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'booking_request':
        return Icons.schedule;
      case 'approval':
        return Icons.check_circle;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }
}
