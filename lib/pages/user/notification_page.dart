import 'package:flutter/material.dart';
import 'package:household_manager/common/page_template.dart';
import 'package:household_manager/widgets/notifications/base_notification.dart';
import 'package:household_manager/widgets/notifications/request_notificatiion.dart';
import 'package:household_manager/widgets/notifications/todo_notification.dart';

const _cardBottomPadding = 12.0;
const _cardInnerPadding = 32.0;
const _widthFactor = 0.5;
const _borderRadius = 8.0;
const _boxPadding = 16.0;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<BaseNotification> notifications = [];

  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMoreNotifications();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreNotifications();
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    // TODO: From here down implement this shit, this delay is here just
    // to know if it works, add something like limit, offset to this and
    // fetch it by parts to prevent huge trafic between cleitn and server
    // so lets say it is some kind of mix of pagination and infinite scroll
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      notifications.addAll([
        RequestNotification(),
        TodoNotification(
            title: 'Another TODO assigned',
            description: 'Another TODO has been assigned to you.'),
      ]);

      // TODO-END: Do not touch :D
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Notifications',
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(_cardInnerPadding),
        itemCount: notifications.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == notifications.length) {
            return Center(child: CircularProgressIndicator());
          }
          return _buildNotificationCard(context, notifications[index]);
        },
      ),
    );
  }

  Widget _buildNotificationCard(
      BuildContext context, BaseNotification notification) {
    return Padding(
      padding: EdgeInsets.only(bottom: _cardBottomPadding),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: _widthFactor,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
              side: BorderSide(color: Colors.grey[600]!),
            ),
            child: Padding(
              padding: EdgeInsets.all(_boxPadding),
              child: notification.build(context),
            ),
          ),
        ),
      ),
    );
  }
}
