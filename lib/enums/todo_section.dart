import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:household_manager/enums/stat_range.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/models/user.dart';

class TodoSection {
  final Color color;
  final String label;
  final List<Todo> Function(List<Todo>, User, StatRange) filter;

  const TodoSection(this.color, this.label, this.filter);

  static final TodoSection activeStat = TodoSection(
    Colors.limeAccent,
    'Active',
    (List<Todo> todos, User member, StatRange range) => todos
        .where((t) =>
            t.createdForId == member.id &&
            t.completedAt == null &&
            t.deletedAt == null &&
            t.deadline.compareTo(Timestamp.now()) > 0 &&
            DateTime.now()
                .subtract(Duration(days: range.days))
                .isBefore(t.createdAt.toDate()))
        .toList()
      ..sort((t1, t2) => t1.deadline.compareTo(t2.deadline)),
  );

  static final TodoSection activePastDeadline = TodoSection(
    Colors.orange,
    'Active Past Time',
    (List<Todo> todos, User member, StatRange range) => todos
        .where((t) =>
            t.createdForId == member.id &&
            t.completedAt == null &&
            t.deletedAt == null &&
            t.deadline.compareTo(Timestamp.now()) <= 0 &&
            DateTime.now()
                .subtract(Duration(days: range.days))
                .isBefore(t.createdAt.toDate()))
        .toList()
      ..sort((t1, t2) => t1.deadline.compareTo(t2.deadline)),
  );

  static final TodoSection activeTodo = TodoSection(
    Colors.limeAccent,
    'Active',
    (List<Todo> todos, User member, StatRange range) {
      final active = activeStat.filter(todos, member, range);
      final activePast = activePastDeadline.filter(todos, member, range);
      return activePast..addAll(active);
    },
  );

  static final TodoSection doneOnTime = TodoSection(
    Colors.green,
    'Done On Time',
    (List<Todo> todos, User member, StatRange range) => todos
        .where((t) =>
            t.createdForId == member.id &&
            t.completedAt != null &&
            t.deletedAt == null &&
            t.completedAt!.compareTo(t.deadline) <= 0 &&
            DateTime.now()
                .subtract(Duration(days: range.days))
                .isBefore(t.completedAt!.toDate()))
        .toList()
      ..sort((t1, t2) => t1.completedAt!.compareTo(t2.completedAt!)),
  );

  static final TodoSection donePastDeadline = TodoSection(
    Colors.red,
    'Done Past Time',
    (List<Todo> todos, User member, StatRange range) => todos
        .where((t) =>
            t.createdForId == member.id &&
            t.completedAt != null &&
            t.deletedAt == null &&
            t.completedAt!.compareTo(t.deadline) > 0 &&
            DateTime.now()
                .subtract(Duration(days: range.days))
                .isBefore(t.completedAt!.toDate()))
        .toList()
      ..sort((t1, t2) => t1.completedAt!.compareTo(t2.completedAt!)),
  );

  static final TodoSection doneTodo = TodoSection(
    Colors.limeAccent,
    'Done',
    (List<Todo> todos, User member, StatRange range) {
      final done = doneOnTime.filter(todos, member, range);
      final donePast = donePastDeadline.filter(todos, member, range);
      return done..addAll(donePast);
    },
  );

  static final TodoSection created = TodoSection(
    Colors.blue,
    'Created',
    (List<Todo> todos, User member, StatRange range) => todos
        .where((t) =>
            t.createdById == member.id &&
            t.deletedAt == null &&
            t.completedAt == null &&
            t.createdAt.compareTo(Timestamp.now()) <= 0 &&
            DateTime.now()
                .subtract(Duration(days: range.days))
                .isBefore(t.createdAt.toDate()))
        .toList()
      ..sort((t1, t2) => t1.createdAt.compareTo(t2.createdAt)),
  );

  static final TodoSection deleted = TodoSection(
    Colors.purpleAccent,
    'Deleted',
    (List<Todo> todos, User member, StatRange range) => todos
        .where((t) =>
            t.createdById == member.id &&
            t.completedAt == null &&
            t.deletedAt != null &&
            t.deletedAt!.compareTo(Timestamp.now()) <= 0 &&
            DateTime.now()
                .subtract(Duration(days: range.days))
                .isBefore(t.deletedAt!.toDate()))
        .toList()
      ..sort((t1, t2) => t1.deletedAt!.compareTo(t2.deletedAt!)),
  );

  static List<TodoSection> get statSections => [
        activeStat,
        activePastDeadline,
        doneOnTime,
        donePastDeadline,
        created,
        deleted,
      ];

  static List<TodoSection> get todoSections => [
        activeTodo,
        doneTodo,
        created,
        deleted,
      ];
}
