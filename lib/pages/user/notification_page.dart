import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/user.dart' as user_model;
import 'package:household_manager/models/user.dart';
import 'package:household_manager/pages/common/loading_page_template.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/widgets/info_bubble.dart';
import 'package:household_manager/widgets/notifications/base_notification.dart';
import 'package:household_manager/widgets/notifications/request_notification.dart';
import 'package:household_manager/widgets/notifications/user_notification.dart';
import 'package:rxdart/rxdart.dart';

const _cardBottomPadding = 12.0;
const _cardInnerPadding = 32.0;
const _widthFactorWeb = 0.6;
const _widthFactorMobile = 1.0;
const _mobileWidthLimitMax = 1000;
const _borderRadius = 8.0;
const _boxPadding = 16.0;
const _searchBarPadding = 8.0;
const _searchBarPaddingTop = 16.0;
const _menuBarGapRight = 8.0;
const _filterWidthFactor = 3;
const _filterMobileGap = 40.0;

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
    return LoadingPageTemplate<(User, Household)>(
      title: 'Notifications',
      showDrawer: true,
      showNotifications: false,
      stream: CombineLatestStream.combine2(
        userService.getUserStream,
        householdService.getHouseholdStream,
        (user, household) => (user!, household!),
      ),
      bodyFunctionWeb: _buildBodyCommon,
      bodyFunctionPhone: _buildBodyCommon,
    );
  }

  Widget _buildBodyCommon(BuildContext context, (User, Household) data) {
    final user = data.$1;
    final household = data.$2;
    final notifications = user.notifications;

    return Column(
      children: [
        _buildSearchAndFilterRow(context),
        Expanded(
          child: FutureBuilder<List<BaseNotification>>(
            future: _buildNotificationsList(household, notifications),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final filteredNotifications =
                  _filterNotifications(snapshot.data!);
              if (filteredNotifications.isEmpty) {
                return InfoBubble(labelText: 'No notifications available.');
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width < _mobileWidthLimitMax
                ? MediaQuery.of(context).size.width - _filterMobileGap
                : MediaQuery.of(context).size.width / _filterWidthFactor,
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
          SizedBox(height: _menuBarGapRight),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
          widthFactor: MediaQuery.of(context).size.width < _mobileWidthLimitMax
              ? _widthFactorMobile
              : _widthFactorWeb,
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
