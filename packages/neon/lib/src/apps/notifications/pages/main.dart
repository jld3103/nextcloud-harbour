part of '../app.dart';

class NotificationsMainPage extends StatefulWidget {
  const NotificationsMainPage({
    required this.bloc,
    super.key,
  });

  final NotificationsBloc bloc;

  @override
  State<NotificationsMainPage> createState() => _NotificationsMainPageState();
}

class _NotificationsMainPageState extends State<NotificationsMainPage> {
  @override
  void initState() {
    super.initState();

    widget.bloc.errors.listen((final error) {
      ExceptionWidget.showSnackbar(context, error);
    });
  }

  @override
  Widget build(BuildContext context) => StandardRxResultBuilder<NotificationsBloc, List<NotificationsNotification>>(
        bloc: widget.bloc,
        state: (final bloc) => bloc.notifications,
        builder: (
          final context,
          final notificationsData,
          final notificationsError,
          final notificationsLoading,
          final _,
        ) =>
            Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              widget.bloc.deleteAllNotifications();
            },
            child: const Icon(MdiIcons.checkAll),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              widget.bloc.refresh();
            },
            child: Column(
              children: [
                ExceptionWidget(
                  notificationsError,
                  onRetry: () {
                    widget.bloc.refresh();
                  },
                ),
                CustomLinearProgressIndicator(
                  visible: notificationsLoading,
                ),
                if (notificationsData != null) ...[
                  Expanded(
                    child: CustomListView<NotificationsNotification>(
                      scrollKey: 'notifications-notifications',
                      withFloatingActionButton: true,
                      items: notificationsData,
                      builder: _buildNotification,
                    ),
                  ),
                ],
              ]
                  .intersperse(
                    const SizedBox(
                      height: 10,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      );

  Widget _buildNotification(
    final BuildContext context,
    final NotificationsNotification notification,
  ) {
    final matchingAppImplementations = Provider.of<List<AppImplementation>>(context, listen: false)
        .where((final a) => a.id == notification.app)
        .toList();

    return ListTile(
      title: Text(notification.subject!),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notification.message!.isNotEmpty) ...[
            Text(
              notification.message!,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(
              height: 5,
            ),
          ],
          Text(CustomTimeAgo.format(DateTime.parse(notification.datetime!))),
        ],
      ),
      leading: matchingAppImplementations.isNotEmpty
          ? matchingAppImplementations.single.buildIcon(
              context,
              width: 40,
              height: 40,
            )
          : SizedBox(
              width: 40,
              height: 40,
              child: CachedURLImage(
                url: notification.icon!,
                requestManager: widget.bloc.requestManager,
                client: widget.bloc.client,
                width: 40,
                height: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
      onTap: () async {
        if (!(await Global.handleNotificationOpening!(notification))) {
          await showDialog(
            context: context,
            builder: (final context) => AlertDialog(
              title: Text(AppLocalizations.of(context).notificationsNextcloudAppNotImplementedYet),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context).close),
                ),
              ],
            ),
          );
        }
      },
      onLongPress: () {
        widget.bloc.deleteNotification(notification);
      },
    );
  }
}
