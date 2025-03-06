import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef EventHandler = Future<dynamic> Function(Map<String, dynamic> event);

/// 接受参数，返回参数，为Map或String
class APNsPush {
  factory APNsPush() => _instance;
  final MethodChannel _channel;

  @visibleForTesting
  APNsPush.private(MethodChannel channel) : _channel = channel;

  static final APNsPush _instance =
      APNsPush.private(const MethodChannel('apns_push'));

  EventHandler? _onReceiveNotification;
  EventHandler? _onOpenNotification;
  EventHandler? _onInAppMessageClick;
  EventHandler? _onPushAuthorityResult;

  ///
  /// 必须先初始化才能执行其他操作(比如接收事件传递)
  ///
  void addEventHandler({
    EventHandler? onReceiveNotification,
    EventHandler? onOpenNotification,
    EventHandler? onInAppMessageClick,
  }) {
    _onReceiveNotification = onReceiveNotification;
    _onOpenNotification = onOpenNotification;
    _onInAppMessageClick = onInAppMessageClick;
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onReceiveNotification":
        return _onReceiveNotification!(call.arguments.cast<String, dynamic>());

      /// App在前台/后台时，点击通知栏的通知，会触发该方法
      case "onOpenNotification":
        return _onOpenNotification!(call.arguments.cast<String, dynamic>());

      /// 点击对应消息通知，App启动，会触发该方法
      case "onInAppMessageClick":
        return _onInAppMessageClick!(call.arguments.cast<String, dynamic>());

      /// 推送权限授权结果回调 {"status":"", "deviceToken":""}
      /// status：(enable、disable、waiting)
      case "onPushAuthorityResult":
        return _onPushAuthorityResult
            ?.call(call.arguments.cast<String, dynamic>());
      default:
        throw UnsupportedError("Unrecognized Event");
    }
  }

  ///
  /// iOS Only
  /// 申请推送权限，注意这个方法只会向用户弹出一次推送权限请求（如果用户不同意，之后只能用户到设置页面里面勾选相应权限），需要开发者选择合适的时机调用。
  ///
  Future<void> registerAPNsPush({EventHandler? onPushAuthorityResult}) async {
    _onPushAuthorityResult = onPushAuthorityResult;
    _channel.invokeMethod('registerAPNsPush');
  }

  ///
  /// 设置应用 Badge（小红点）
  ///
  /// @param {Int} badge
  ///
  Future setBadge(int badge) async {
    await _channel.invokeMethod('setBadge', badge);
  }

  ///
  /// 获取角标数量
  ///
  Future<int> getBadgeNum() async {
    return await _channel.invokeMethod('getBadge');
  }


  ///
  /// 获取通知栏，剩余的通知数量
  ///
  Future<int> getNotificationsCount() async {
    return await _channel.invokeMethod('getNotificationsCount');
  }


  ///
  /// 角标数字加+1
  ///
  Future badgeNumberAdd() async {
    await _channel.invokeMethod('badgeNumberAdd');
  }

  ///
  /// 角标数字加-1
  ///
  Future badgeNumberSub() async {
    await _channel.invokeMethod('badgeNumberSub');
  }

  /// APP活跃在前台时是否展示通知
  void setUnShowAtTheForeground({bool unShow = false}) {
    _channel.invokeMethod('setUnShowAtTheForeground', unShow);
  }

  ///
  /// 清空通知栏上的所有通知。
  ///
  Future clearAllNotifications() async {
    await _channel.invokeMethod('clearAllNotifications');
  }

  ///
  /// 清空通知栏上某个通知
  /// @param notificationId 通知 id，即：LocalNotification id
  ///
  void clearNotification({int notificationId = 0}) {
    _channel.invokeListMethod("clearNotification", notificationId);
  }

  ///
  /// 点击推送启动应用的时候原生会将该 notification 缓存起来，该方法用于获取缓存 notification
  /// 注意：notification 可能是 remoteNotification 和 localNotification，两种推送字段不一样。
  /// 如果不是通过点击推送启动应用，比如点击应用 icon 直接启动应用，notification 会返回 @{}。
  /// @param {Function} callback = (Object) => {}
  ///
  Future<Map<dynamic, dynamic>> getLaunchAppNotification() async {
    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('getLaunchAppNotification');
    return result;
  }

  /// 获取 apple APNs token
  Future<String> getAppleAPNsToken() async {
    final String token = await _channel.invokeMethod('getAppleAPNSToken');
    return token;
  }

  /// 检测通知授权状态是否打开
  Future<bool> isNotificationEnabled() async {
    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('isNotificationEnabled');
    bool isEnabled = result['isEnabled'];
    return isEnabled;
  }

  /// 跳转至系统设置中应用设置界面
  void openSettingsForNotification() {
    _channel.invokeMethod('openSettingsForNotification');
  }
}
