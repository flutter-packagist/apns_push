
# iOS原生推送

## 支持功能
* 注册推送
*  获取DeviceToken
*  获取推送权限状态
*  角标设置，角标获取
*  通知栏留存通知数量获取
*  前后台切换或App启动，自动根据通知栏留存数量刷新角标


## 引入安装包
 
```dart
addcn_socket:
  git:
    url: https://github.com/flutter-packagist/apns_push.git
```

##  注册推送

```dart
APNsPush().registerAPNsPush(
  onPushAuthorityResult: (
    Map<String, dynamic> result,
  ) async {
    print("註冊通知結果: \n${result.toString()}");
  },
);
```
     
## 添加监听
```dart
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
``` 
 
## 获取DeviceToken 
```dart
final deviceToken = await APNsPush().getAppleAPNsToken();
print("deviceToken: $deviceToken");
```

## 更多方法参考APNsPush类

 
 


