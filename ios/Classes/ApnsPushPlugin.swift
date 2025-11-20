import Flutter
import UIKit


// MARK: 调用Flutter方法
enum PushMethod: String {

    // 前台/后台运行时，收到推送
    case onReceiveNotification
    
    // 前台/后台运行时，点击了通知内容
    case onOpenNotification

    // 点击通知启动了App
    case onInAppMessageClick

    // 推送权限授权结果回调 {"status":"", "deviceToken":""}
    // status：(enable、disable、error)
    case onPushAuthorityResult
}

public class ApnsPushPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {

    private static var channel: FlutterMethodChannel = FlutterMethodChannel.init();

    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "apns_push", binaryMessenger: registrar.messenger())
        let instance = ApnsPushPlugin()
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    let userCenter = UNUserNotificationCenter.current()
    
    let shareGroupData: UserDefaults? = UserDefaults.init(suiteName: "group.100.shareData")
    
    private var deviceAPNsToken: String = ""
    private var launchRemoteNotification:[String : Any] = [:]

    public override init() {
        super.init()
        userCenter.delegate = self
        deviceAPNsToken = UserDefaults.standard.string(forKey: "iOS_DeviceToken") ?? ""
    }
    

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
                
        // 接受参数，返回参数，全部是map类型
        
        switch call.method {
            // 申请推送权限
            case "registerAPNsPush":
                requestNotificationAuthorization()
            
            // 设置角标
            case "setBadge":
                setBadge(number: call.arguments ?? 0)

            // 获取角标数量
            case "getBadge":
                result(getBadge())

            // 角标+1
            case "badgeNumberAdd":
                badgeNumberAdd()
        
            // 角标-1
            case "badgeNumberSub":
                badgeNumberSub()
        
            // 获取通知栏现有消息数量
            case "getNotificationsCount":
                getNotificationsCount(result: result);
        
            // 清空通知栏上的所有通知
            case "clearAllNotifications":
                clearAllNotifications()

            // 删除通知栏上某个通知
            case "clearNotification":
                clearNotification(identifier: "\(call.arguments ?? "")")
            
            // 获取DeviceToken
            case "getAppleAPNSToken":
                result(deviceAPNsToken)
                
            // 通知权限是否打开
            case "isNotificationEnabled":
                isNotificationEnabled(result: result)

            // 跳转到应设置界面
            case "openSettingsForNotification":
                openNotificationSettings()
            
            // 获取通过推送启动App的参数
            case "getLaunchAppNotification":
                result(launchRemoteNotification)
            
            default:
              result(FlutterMethodNotImplemented)
        }
    }

}

// 推送相关设置
extension ApnsPushPlugin  {
    
    func requestNotificationAuthorization() {
        userCenter.requestAuthorization(options: [.alert, .badge, .sound]) {
            granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("推送權限獲取失敗")
                ApnsPushPlugin.channel.invokeMethod(PushMethod.onPushAuthorityResult.rawValue, arguments: ["status":"disable", "deviceToken":""])
            }
        }
    }
    
    
    func isNotificationEnabled(result: @escaping FlutterResult) {
        userCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
                
            case .authorized,.provisional:
                result(["isEnabled":true, "status":"authorized"]);
                
            case .denied:
                result(["isEnabled":false, "status":"denied"]);

            case .notDetermined:
                result(["isEnabled":false, "status":"notDetermined"]);
                
            default:
                result(["isEnabled":false, "status":"unknown"]);
            }
        }
    }
    
    func setBadge(number: Any){
        let num:Int = (number as! Int)
        
        if(num<0)  { return }
        
        // 同步角标数量到扩展程序
        shareGroupData?.set("\(num)", forKey: "AppBadgeCount")
        
        if #available(iOS 17.0, *) {
            userCenter.setBadgeCount(num)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = num;
        }
    }
    
    func refreshBadge(){
        userCenter.getDeliveredNotifications { notifications in
            let badgeCount = notifications.count
            DispatchQueue.main.async {
                self.setBadge(number: badgeCount)
            }
        }
    }

    func getBadge()-> Int {
        return UIApplication.shared.applicationIconBadgeNumber
    }
    
    func getNotificationsCount(result: @escaping FlutterResult){
        // 获取通知栏的通知数量
        userCenter.getDeliveredNotifications { notifications in
            let badgeCount = notifications.count
            DispatchQueue.main.async {
                result(badgeCount)
            }
        }
    }

    func badgeNumberAdd() {
        let badgeCount = getBadge()
        self.setBadge(number: badgeCount + 1)
    }
    
    func badgeNumberSub() {
        let badgeCount = getBadge()
        self.setBadge(number: badgeCount - 1)
    }
    
    func clearAllNotifications() {
        setBadge(number: 0)
        userCenter.removeAllDeliveredNotifications()
        userCenter.removeAllPendingNotificationRequests()
    }
    
    func clearNotification(identifier: String) {
        if(!identifier.isEmpty) {
            self.badgeNumberSub()
            userCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
            userCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        }
    }
    
    func openNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
}

// 注册Token和消息接收处理
extension ApnsPushPlugin {
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        // 检查是否有远程推送通知的 key
        if let remoteNotification = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            launchRemoteNotification = remoteNotification
//             let alertC = UIAlertController.init(title: "启动参数", message: "\(launchRemoteNotification)", preferredStyle: .alert)
//             let action = UIAlertAction(title: "知道了", style: .default)
//             alertC.addAction(action)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self = self else { return }
                self.badgeNumberSub()
//                UIApplication.shared.keyWindow?.rootViewController?.present(alertC, animated: true)
                // 延时回调，等待Flutter引擎初始化完成再回调
                ApnsPushPlugin.channel.invokeMethod(PushMethod.onInAppMessageClick.rawValue, arguments: remoteNotification)
            }
        }
        return true
    }
    
//    public func applicationWillResignActive(_ application: UIApplication) {
//        // App即将进入后台时，更正角标数量和通知栏现有通知数量一致
//        refreshBadge()
//    }
    
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("iOS Device Token: \(tokenString)")
        deviceAPNsToken = tokenString
        UserDefaults.standard.set(tokenString, forKey: "iOS_DeviceToken")
        ApnsPushPlugin.channel.invokeMethod(PushMethod.onPushAuthorityResult.rawValue, arguments: ["status":"enable", "deviceToken":tokenString])
    }

    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Device Token 注册失败: \(error.localizedDescription)")
        ApnsPushPlugin.channel.invokeMethod(PushMethod.onPushAuthorityResult.rawValue, arguments: ["status":"error", "deviceToken":""])
    }
    
    // MARK: - 处理推送通知（前台收到通知时）
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("前台收到推送(willPresent): \(userInfo)")
        ApnsPushPlugin.channel.invokeMethod(PushMethod.onReceiveNotification.rawValue, arguments: userInfo)
        if  let aps = userInfo["aps"] as? [String : Any] {
            let contentAvailable = aps["content-available"] as? Int
            if((contentAvailable) != 0){
                completionHandler([.alert, .sound, .badge])
            }
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("后台收到推送: \(userInfo)")
        ApnsPushPlugin.channel.invokeMethod(PushMethod.onReceiveNotification.rawValue, arguments: userInfo)
    }
    
    // 有需要下载的资源时会执行这个
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
        print("后台收到推送(需要下载资源): \(userInfo)")
        ApnsPushPlugin.channel.invokeMethod(PushMethod.onReceiveNotification.rawValue, arguments: userInfo)
        completionHandler(.newData)
        return true
    }
    
    // 点击通知触发该方法
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
//        refreshBadge()
        self.badgeNumberSub()
        ApnsPushPlugin.channel.invokeMethod(PushMethod.onOpenNotification.rawValue, arguments: userInfo)
        completionHandler()
    }
}

