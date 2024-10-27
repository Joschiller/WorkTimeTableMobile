import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/selectable_card.dart';
import 'package:work_time_table_mobile/models/user.dart';

class UserItem extends StatelessWidget {
  const UserItem({
    super.key,
    required this.user,
    required this.selected,
    required this.currentUser,
  });

  final User user;
  final bool selected;
  final bool currentUser;

  @override
  Widget build(BuildContext context) => SelectableCard(
        selected: selected,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(child: Text(user.name)),
            if (currentUser) const Icon(Icons.person),
          ],
        ),
      );
}
