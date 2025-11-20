import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

typedef EventHandler = Future<dynamic> Function(Map<String, dynamic> event);

/// 接受参数，返回参数，为Map或String
class APNsPush {
  factory APNsPush() => _instance;
  static final APNsPush _instance = APNsPush._internal();
  APNsPush._internal();

  ///
  /// 先添加事件监听
  ///
  void addEventHandler({
    EventHandler? onReceiveNotification,
    EventHandler? onOpenNotification,
    EventHandler? onInAppMessageClick,
  }) {
    APNsPushPlatform.instance.addEventHandler(
      onReceiveNotification: onReceiveNotification,
      onOpenNotification: onOpenNotification,
      onInAppMessageClick: onInAppMessageClick,
    );
  }

  ///
  /// iOS Only
  /// 申请推送权限，注意这个方法只会向用户弹出一次推送权限请求（如果用户不同意，之后只能用户到设置页面里面勾选相应权限），需要开发者选择合适的时机调用。
  ///
  Future registerAPNsPush({EventHandler? onPushAuthorityResult}) async {
    return APNsPushPlatform.instance.registerAPNsPush(
      onPushAuthorityResult: onPushAuthorityResult,
    );
  }

  ///
  /// 设置应用 Badge（小红点）
  ///
  /// @param {Int} badge
  ///
  Future setBadge(int badge) async {
    return APNsPushPlatform.instance.setBadge(badge);
  }

  ///
  /// 获取角标数量
  ///
  Future<int> getBadgeNum() async {
    return APNsPushPlatform.instance.getBadgeNum();
  }

  ///
  /// 获取通知栏，剩余的通知数量
  ///
  Future<int> getNotificationsCount() async {
    return APNsPushPlatform.instance.getNotificationsCount();
  }

  ///
  /// 角标数字加+1
  ///
  Future badgeNumberAdd() async {
    return APNsPushPlatform.instance.badgeNumberAdd();
  }

  ///
  /// 角标数字加-1
  ///
  Future badgeNumberSub() async {
    return APNsPushPlatform.instance.badgeNumberSub();
  }

  ///
  /// 清空通知栏上的所有通知。
  ///
  Future clearAllNotifications() async {
    return APNsPushPlatform.instance.clearAllNotifications();
  }

  ///
  /// 清空通知栏上某个通知
  /// @param notificationId 通知 id，即：LocalNotification id
  ///
  void clearNotification({int notificationId = 0}) {
    APNsPushPlatform.instance.clearNotification(notificationId: notificationId);
  }

  ///
  /// 点击推送启动应用的时候原生会将该 notification 缓存起来，该方法用于获取缓存 notification
  /// 注意：notification 可能是 remoteNotification 和 localNotification，两种推送字段不一样。
  /// 如果不是通过点击推送启动应用，比如点击应用 icon 直接启动应用，notification 会返回 @{}。
  /// @param {Function} callback = (Object) => {}
  ///
  Future<Map<dynamic, dynamic>> getLaunchAppNotification() async {
    return APNsPushPlatform.instance.getLaunchAppNotification();
  }

  /// 获取 apple APNs token
  Future<String> getAppleAPNsToken() async {
    return APNsPushPlatform.instance.getAppleAPNsToken();
  }

  /// 检测通知授权状态是否打开
  Future<bool> isNotificationEnabled() async {
    return APNsPushPlatform.instance.isNotificationEnabled();
  }

  /// 跳转至系统设置中应用设置界面
  void openSettingsForNotification() {
    APNsPushPlatform.instance.openSettingsForNotification();
  }
}

abstract class APNsPushPlatform extends PlatformInterface {
  /// Constructs a TesPlatform.
  APNsPushPlatform() : super(token: _token);

  static final Object _token = Object();

  static APNsPushPlatform _instance = MethodChannelAPNsPush();

  /// The default instance of [TesPlatform] to use.
  ///
  /// Defaults to [MethodChannelTes].
  static APNsPushPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TesPlatform] when
  /// they register themselves.
  static set instance(APNsPushPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  void addEventHandler({
    EventHandler? onReceiveNotification,
    EventHandler? onOpenNotification,
    EventHandler? onInAppMessageClick,
  }) {
    throw UnimplementedError('addEventHandler() has not been implemented.');
  }

  Future<void> registerAPNsPush({EventHandler? onPushAuthorityResult}) async {
    throw UnimplementedError('registerAPNsPush() has not been implemented.');
  }

  Future setBadge(int badge) async {
    throw UnimplementedError('setBadge() has not been implemented.');
  }

  Future<int> getBadgeNum() async {
    throw UnimplementedError('getBadgeNum() has not been implemented.');
  }

  Future<int> getNotificationsCount() async {
    throw UnimplementedError(
        'getNotificationsCount() has not been implemented.');
  }

  Future badgeNumberAdd() async {
    throw UnimplementedError('badgeNumberAdd() has not been implemented.');
  }

  Future badgeNumberSub() async {
    throw UnimplementedError('badgeNumberSub() has not been implemented.');
  }

  Future clearAllNotifications() async {
    throw UnimplementedError(
        'clearAllNotifications() has not been implemented.');
  }

  void clearNotification({int notificationId = 0}) {
    throw UnimplementedError('clearNotification() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>> getLaunchAppNotification() async {
    throw UnimplementedError(
        'getLaunchAppNotification() has not been implemented.');
  }

  Future<String> getAppleAPNsToken() async {
    throw UnimplementedError('getAppleAPNsToken() has not been implemented.');
  }

  Future<bool> isNotificationEnabled() async {
    throw UnimplementedError(
        'isNotificationEnabled() has not been implemented.');
  }

  void openSettingsForNotification() {
    throw UnimplementedError(
        'openSettingsForNotification() has not been implemented.');
  }
}

class MethodChannelAPNsPush extends APNsPushPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('apns_push');

  EventHandler? _onReceiveNotification;
  EventHandler? _onOpenNotification;
  EventHandler? _onInAppMessageClick;
  EventHandler? _onPushAuthorityResult;

  ///
  /// 必须先初始化才能执行其他操作(比如接收事件传递)
  ///
  @override
  void addEventHandler({
    EventHandler? onReceiveNotification,
    EventHandler? onOpenNotification,
    EventHandler? onInAppMessageClick,
  }) {
    _onReceiveNotification = onReceiveNotification;
    _onOpenNotification = onOpenNotification;
    _onInAppMessageClick = onInAppMessageClick;
    methodChannel.setMethodCallHandler(_handleMethod);
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
  @override
  Future<void> registerAPNsPush({EventHandler? onPushAuthorityResult}) async {
    _onPushAuthorityResult = onPushAuthorityResult;
    methodChannel.invokeMethod('registerAPNsPush');
  }

  ///
  /// 设置应用 Badge（小红点）
  ///
  /// @param {Int} badge
  ///
  @override
  Future setBadge(int badge) async {
    return methodChannel.invokeMethod('setBadge', badge);
  }

  ///
  /// 获取角标数量
  ///
  @override
  Future<int> getBadgeNum() async {
    return await methodChannel.invokeMethod('getBadge');
  }

  ///
  /// 获取通知栏，剩余的通知数量
  ///
  @override
  Future<int> getNotificationsCount() async {
    return await methodChannel.invokeMethod('getNotificationsCount');
  }

  ///
  /// 角标数字加+1
  ///
  @override
  Future badgeNumberAdd() async {
    return methodChannel.invokeMethod('badgeNumberAdd');
  }

  ///
  /// 角标数字加-1
  ///
  @override
  Future badgeNumberSub() async {
    return methodChannel.invokeMethod('badgeNumberSub');
  }

  ///
  /// 清空通知栏上的所有通知。
  ///
  @override
  Future clearAllNotifications() async {
    return methodChannel.invokeMethod('clearAllNotifications');
  }

  ///
  /// 清空通知栏上某个通知
  /// @param notificationId 通知 id，即：LocalNotification id
  ///
  @override
  void clearNotification({int notificationId = 0}) {
    methodChannel.invokeListMethod("clearNotification", notificationId);
  }

  ///
  /// 点击推送启动应用的时候原生会将该 notification 缓存起来，该方法用于获取缓存 notification
  /// 注意：notification 可能是 remoteNotification 和 localNotification，两种推送字段不一样。
  /// 如果不是通过点击推送启动应用，比如点击应用 icon 直接启动应用，notification 会返回 @{}。
  /// @param {Function} callback = (Object) => {}
  ///
  @override
  Future<Map<dynamic, dynamic>> getLaunchAppNotification() async {
    final Map<dynamic, dynamic> result =
        await methodChannel.invokeMethod('getLaunchAppNotification');
    return result;
  }

  /// 获取 apple APNs token
  @override
  Future<String> getAppleAPNsToken() async {
    final String token = await methodChannel.invokeMethod('getAppleAPNSToken');
    return token;
  }

  /// 检测通知授权状态是否打开
  @override
  Future<bool> isNotificationEnabled() async {
    final Map<dynamic, dynamic> result =
        await methodChannel.invokeMethod('isNotificationEnabled');
    bool isEnabled = result['isEnabled'];
    return isEnabled;
  }

  /// 跳转至系统设置中应用设置界面
  @override
  void openSettingsForNotification() {
    methodChannel.invokeMethod('openSettingsForNotification');
  }
}
