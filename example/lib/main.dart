import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:apns_push/apns_push.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _apnsPushPlugin = APNsPush();

  String info = '';

  @override
  void initState() {
    super.initState();
    APNsPush().addEventHandler(
      onReceiveNotification: (Map<String, dynamic> event) {
        print('onReceiveNotification: $event');
        return Future.value();
      },
      onOpenNotification: (Map<String, dynamic> event) {
        print('onOpenNotification: $event');
        return Future.value();
      },
      onInAppMessageClick: (Map<String, dynamic> event) {
        print('onInAppMessageClick: $event');
        _setInfo('onInAppMessageClick: \n${event.toString()}');
        return Future.value();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('推送通知測試'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "信息顯示",
                style: TextStyle(fontSize: 20, color: Colors.blue),
              ),
              const SizedBox(height: 20),
              SelectableText(
                info,
                maxLines: 10,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16, color: Colors.black, height: 1.5),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                direction: Axis.horizontal,
                children: [
                  TextButton(
                    child: const Text('檢查通知權限'),
                    onPressed: () async {
                      _apnsPushPlugin.isNotificationEnabled().then(
                        (value) {
                          _setInfo(value ? '已開啟' : '未開啟');
                        },
                      );
                    },
                  ),
                  TextButton(
                    child: const Text('註冊通知'),
                    onPressed: () async {
                      _apnsPushPlugin.registerAPNsPush(
                        onPushAuthorityResult: (
                          Map<String, dynamic> result,
                        ) async {
                          _setInfo("註冊通知結果: \n${result.toString()}");
                        },
                      );
                    },
                  ),
                  TextButton(
                    child: const Text('獲取Token'),
                    onPressed: () async {
                      _apnsPushPlugin.getAppleAPNsToken().then(
                        (value) {
                          _setInfo("DeviceToken: $value");
                        },
                      );
                    },
                  ),
                  TextButton(
                    child: const Text('設定前景不顯示通知'),
                    onPressed: () async {
                      _apnsPushPlugin.setUnShowAtTheForeground(unShow: true);
                    },
                  ),
                  TextButton(
                    child: const Text('清除所有通知'),
                    onPressed: () async {
                      _apnsPushPlugin.clearAllNotifications();
                    },
                  ),
                  TextButton(
                    child: const Text('获取角標数字'),
                    onPressed: () async {
                      _apnsPushPlugin.getBadgeNum().then(
                        (value) {
                          _setInfo("角標數字: $value");
                        },
                      );
                    },
                  ),
                  TextButton(
                    child: const Text('通知栏消息数量'),
                    onPressed: () async {
                      _apnsPushPlugin.getNotificationsCount().then(
                        (value) {
                          _setInfo("通知栏消息数量: $value");
                        },
                      );
                    },
                  ),
                  TextButton(
                    child: const Text('設定角標'),
                    onPressed: () async {
                      int badge = Random().nextInt(99) + 1;
                      _setInfo("設定角標: $badge");
                      _apnsPushPlugin.setBadge(badge);
                    },
                  ),
                  TextButton(
                    child: const Text('角標數字加1'),
                    onPressed: () async {
                      _apnsPushPlugin.badgeNumberAdd();
                      _apnsPushPlugin.getBadgeNum().then(
                        (value) {
                          _setInfo("加1後的角標數字: $value");
                        },
                      );
                    },
                  ),
                  TextButton(
                    child: const Text('角標數字減1'),
                    onPressed: () async {
                      _apnsPushPlugin.badgeNumberSub();
                      _apnsPushPlugin.getBadgeNum().then(
                        (value) {
                          _setInfo("減1後的角標數字: $value");
                        },
                      );
                    },
                  ),
                  TextButton(
                    child: const Text('關閉角標'),
                    onPressed: () async {
                      _apnsPushPlugin.setBadge(0);
                      _apnsPushPlugin.getBadgeNum().then(
                        (value) {
                          _setInfo("当前角標數字: $value");
                        },
                      );
                    },
                  ),
                  TextButton(
                    child: const Text('获取启动参数'),
                    onPressed: () {
                      _apnsPushPlugin.getLaunchAppNotification().then(
                        (value) {
                          _setInfo("启动参数: \n${value.toString()}");
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setInfo(String str) {
    info = str;
    setState(() {});
  }
}
