import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_time_table_mobile/blocs/current_user_cubit.dart';
import 'package:work_time_table_mobile/blocs/user_cubit.dart';
import 'package:work_time_table_mobile/components/confirmable_alert_dialog.dart';
import 'package:work_time_table_mobile/components/editable_list.dart';
import 'package:work_time_table_mobile/components/user/user_input_dialog.dart';
import 'package:work_time_table_mobile/components/user/user_item.dart';
import 'package:work_time_table_mobile/daos/current_user_dao.dart';
import 'package:work_time_table_mobile/daos/user_dao.dart';
import 'package:work_time_table_mobile/models/user.dart';
import 'package:work_time_table_mobile/services/user_service.dart';
import 'package:work_time_table_mobile/stream_helpers/context/context_dependent_value.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({
    super.key,
    required this.immediatelyShowAddDialog,
  });

  final bool immediatelyShowAddDialog;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => UserCubit(UserService(
          context.read<UserDao>(),
          context.read<CurrentUserDao>(),
        )),
        child: BlocSelector<UserCubit, List<User>, List<User>>(
          selector: (state) => state..sort((a, b) => a.name.compareTo(b.name)),
          builder: (context, users) =>
              BlocBuilder<CurrentUserCubit, ContextDependentValue<User>>(
            builder: (context, currentUser) => UserScreenContent(
              immediatelyShowAddDialog: immediatelyShowAddDialog,
              users: users,
              currentUser: currentUser,
            ),
          ),
        ),
      );
}

class UserScreenContent extends StatefulWidget {
  const UserScreenContent({
    super.key,
    required this.immediatelyShowAddDialog,
    required this.users,
    required this.currentUser,
  });

  final bool immediatelyShowAddDialog;
  final List<User> users;
  final ContextDependentValue<User> currentUser;

  @override
  State<UserScreenContent> createState() => _UserScreenContentState();
}

class _UserScreenContentState extends State<UserScreenContent> {
  @override
  void initState() {
    super.initState();
    if (widget.immediatelyShowAddDialog) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _showAddDialog(
            context,
            widget.users.map((user) => user.name).toList(),
            (name) => context.read<UserCubit>().addUser(name),
          ));
    }
  }

  void _showAddDialog(
    BuildContext context,
    List<String> occupiedNames,
    void Function(String name) doAdd,
  ) =>
      showDialog(
        context: context,
        builder: (context) => UserInputDialog(
          dialogTitle: 'Add User',
          actionText: 'Add',
          initialValue: '',
          occupiedNames: occupiedNames,
          onConfirm: doAdd,
        ),
      );

  Future<void> _showDeletionConfirmation(
    BuildContext context,
    Future<void> Function() doDelete,
  ) async =>
      await showDialog(
        context: context,
        builder: (context) => ConfirmableAlertDialog(
          title: 'Delete Users',
          content: const Text(
              'Do you really want to delete the selected users permanently?'),
          actionText: 'Delete',
          isActionNegative: true,
          onCancel: Navigator.of(context).pop,
          onConfirm: () async {
            await doDelete();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
        ),
      );

  void _showRenameDialog(
    BuildContext context,
    String currentName,
    List<String> occupiedNames,
    void Function(String name) doRename,
  ) =>
      showDialog(
        context: context,
        builder: (context) => UserInputDialog(
          dialogTitle: 'Rename User',
          actionText: 'Rename',
          initialValue: currentName,
          occupiedNames: occupiedNames,
          onConfirm: doRename,
        ),
      );

  @override
  Widget build(BuildContext context) => EditableList(
        title: 'Users',
        items: widget.users,
        templateItem: User(id: -1, name: 'User ...'),
        emptyText: 'There do not exist any users yet.',
        addFirstText: 'Add first user',
        buildItem: (item, selected) => UserItem(
          user: item,
          selected: selected,
          currentUser: switch (widget.currentUser) {
            NoContextValue() => false,
            ContextValue(value: var user) => user.id == item.id,
          },
          onEditTap: () => _showRenameDialog(
            context,
            item.name,
            widget.users
                .where((user) => user.id != item.id)
                .map((user) => user.name)
                .toList(),
            (name) => context.read<UserCubit>().renameUser(item.id, name),
          ),
        ),
        onAdd: () => _showAddDialog(
          context,
          widget.users.map((user) => user.name).toList(),
          (name) => context.read<UserCubit>().addUser(name),
        ),
        onRemove: (items) => _showDeletionConfirmation(
          context,
          () => context.read<UserCubit>().deleteUsers(
                items.map((user) => user.id).toList(),
                true,
              ),
        ),
        onTapItem: (index) =>
            context.read<CurrentUserCubit>().selectUser(widget.users[index].id),
      );
}
