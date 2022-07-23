import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:neon/src/models/account.dart';
import 'package:neon/src/neon.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:rx_bloc/rx_bloc.dart';
import 'package:rxdart/rxdart.dart';

part 'user_status.rxb.g.dart';

abstract class UserStatusBlocEvents {}

abstract class UserStatusBlocStates {
  BehaviorSubject<Result<UserStatus?>> get userStatus;
}

@RxBloc()
class UserStatusBloc extends $UserStatusBloc {
  UserStatusBloc(
    this._requestManager,
    this._account,
    this._activeAccountStream,
  ) {
    _activeAccountStreamSubscription = _activeAccountStream.listen((final activeAccount) {
      _cancelTimer();
      final thisAccountActive = activeAccount == _account;
      _timer = instantPeriodicTimer(
        const Duration(minutes: 5),
        (final _) async {
          if (thisAccountActive) {
            await _heartbeat();
          }
          _loadUserStatus();
        },
      );
    });
  }

  void _loadUserStatus() {
    _requestManager
        .wrapNextcloud<UserStatus?, UserStatusGetUserStatus, void, NextcloudUserStatusClient>(
          _account.client.id,
          _account.client.userStatus,
          'user-status',
          () async => (await _account.client.userStatus.getStatus())!,
          (final response) => response.ocs?.data,
          preloadCache: true,
        )
        .listen(_userStatusSubject.add);
  }

  Future _heartbeat() async {
    return;

    // TODO: https://github.com/jld3103/nextcloud-neon/issues/10
    // ignore: dead_code
    try {
      await _account.client.userStatus.heartbeat(UserStatusHeartbeat(status: UserStatusTypeEnum.online));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _cancelTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  final RequestManager _requestManager;
  final Account _account;
  final BehaviorSubject<Account?> _activeAccountStream;
  late final StreamSubscription<Account?> _activeAccountStreamSubscription;
  Timer? _timer;

  final _userStatusSubject = BehaviorSubject<Result<UserStatus?>>();

  @override
  void dispose() {
    _cancelTimer();
    // ignore: discarded_futures
    _activeAccountStreamSubscription.cancel();
    // ignore: discarded_futures
    _userStatusSubject.close();
    super.dispose();
  }

  @override
  BehaviorSubject<Result<UserStatus?>> _mapToUserStatusState() => _userStatusSubject;
}

Timer instantPeriodicTimer(
  final Duration duration,
  final void Function(Timer timer) callback,
) {
  final timer = Timer.periodic(duration, callback);
  callback(timer);
  return timer;
}
