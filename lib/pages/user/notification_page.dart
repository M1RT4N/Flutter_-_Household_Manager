import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/user.dart' as user_model;
import 'package:household_manager/pages/common/page_template.dart';
import 'package:household_manager/widgets/notifications/base_notification.dart';
import 'package:household_manager/widgets/notifications/request_notification.dart';
import 'package:household_manager/widgets/notifications/user_notification.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:rxdart/rxdart.dart';

const _cardBottomPadding = 12.0;
const _cardInnerPadding = 32.0;
const _widthFactor = 0.5;
const _borderRadius = 8.0;
const _boxPadding = 16.0;
const _searchBarPadding = 8.0;
const _searchBarPaddingTop = 16.0;
const _menuBarGapRight = 8.0;
const _noNotificationsFontSize = 16.0;
const _noNotificationsPaddingTop = 25.0;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final userService = GetIt.instance<UserService>();
  final householdService = GetIt.instance<HouseholdService>();
  String _searchQuery = '';
  bool _showHidden = false;

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Notifications',
      showDrawer: true,
      bodyFunction: _buildBody,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        _buildSearchAndFilterRow(context),
        Expanded(
          child: LoadingStreamBuilder(
            stream: CombineLatestStream.combine2(
              userService.getUserStream,
              householdService.getHouseholdStream,
              (user, household) => [user, household],
            ),
            builder: (context, data) {
              final user = (data as List)[0] as user_model.User?;
              final household = (data)[1] as Household?;
              final notifications = user?.notifications ?? [];

              return FutureBuilder<List<BaseNotification>>(
                future: _buildNotificationsList(household, notifications),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final filteredNotifications =
                      _filterNotifications(snapshot.data!);
                  if (filteredNotifications.isEmpty) {
                    return _buildNoNotificationsMessage();
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(_cardInnerPadding),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(
                          context, filteredNotifications[index]);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: _searchBarPaddingTop,
          left: _searchBarPadding,
          right: _searchBarPadding,
          bottom: _searchBarPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          SizedBox(width: _menuBarGapRight),
          Row(
            children: [
              Checkbox(
                value: _showHidden,
                onChanged: (value) {
                  setState(() {
                    _showHidden = value!;
                  });
                },
              ),
              Text('Show hidden'),
            ],
          ),
        ],
      ),
    );
  }

  List<BaseNotification> _filterNotifications(
      List<BaseNotification> notifications) {
    return notifications.where((notification) {
      if (notification is UserNotification) {
        final matchesSearch =
            notification.notification.title.contains(_searchQuery) ||
                notification.notification.description.contains(_searchQuery);
        final matchesHidden =
            _showHidden || !notification.notification.isHidden;
        return matchesSearch && matchesHidden;
      }
      return true;
    }).toList();
  }

  Future<List<BaseNotification>> _buildNotificationsList(
      Household? household, List<user_model.Notification> notifications) async {
    final List<BaseNotification> allNotifications = [
      ...await Future.wait(
        (household?.requested ?? []).map((userId) async {
          final user = await userService.fetchUser(userId);
          return RequestNotification(user: user);
        }),
      ),
      ...notifications
          .map((notification) => UserNotification(notification: notification))
          .toList()
        ..sort((a, b) => b.notification.id.compareTo(a.notification.id)),
    ];
    return allNotifications;
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

  Widget _buildNoNotificationsMessage() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: _noNotificationsPaddingTop),
        child: ConstrainedBox(
          constraints: BoxConstraints(),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
              side: BorderSide(color: Colors.grey[600]!),
            ),
            child: Padding(
              padding: EdgeInsets.all(_boxPadding),
              child: Text(
                'No notifications available.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: _noNotificationsFontSize),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
