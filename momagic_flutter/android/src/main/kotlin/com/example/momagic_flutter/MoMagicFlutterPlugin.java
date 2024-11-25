package com.example.momagic_flutter;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;


import com.momagic.DATB;
import com.momagic.PreferenceUtil;
import com.momagic.TokenReceivedListener;


import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

@SuppressWarnings("MoMagicFlutterPlugin")
public class MoMagicFlutterPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    @SuppressLint("StaticFieldLeak")
    static Context context;
    Activity activity;
    MethodChannel channel;
    private String  notificationToken;

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    }

    @Override
    public void onDetachedFromActivity() {
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), MoMagicConstant.IZ_PLUGIN_NAME); //define the chanel name
        channel.setMethodCallHandler(this);

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    // Handle the all methods
    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case iZootoConstant.IZ_ANDROID_INIT:
                try {

                        DATB.initialize(context).setTokenReceivedListener(new TokenReceivedListener() {
                                    @Override
                                    public void onTokenReceived(String s) {
                                        Log.e("Device Token","Token"+s);

                                        channel.invokeMethod("onToken",s);
                                    }
                                })
                                .build();

                } catch (Exception ex) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString());
                }
                break;

            case MoMagicConstant.IZ_SET_SUBSCRIPTION:
                try {
                    boolean setSubscription = (boolean) call.arguments;
                    DATB.setSubscription(setSubscription);
                } catch (Exception ex) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString());
                }
                break;

            case MoMagicConstant.IZ_FIREBASE_ANALYTICS:
                try {
                    boolean trackFirebaseAnalytics = (boolean) call.arguments;
                    DATB.setFirebaseAnalytics(trackFirebaseAnalytics);
                } catch (Exception ex) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString());
                }
                break;

            case MoMagicConstant.IZ_ADD_EVENTS:
                try {
                    String eventName = call.argument(MoMagicConstant.IZ_EVENT_NAME);
                    HashMap<String, Object> hashMapEvent = new HashMap<>();
                    hashMapEvent = call.argument(MoMagicConstant.IZ_EVENT_VALUE);
                    DATB.addEvent(eventName, hashMapEvent);
                } catch (Exception ex) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString());
                }
                break;

            case MoMagicConstant.IZ_ADD_PROPERTIES:
                try {
                    HashMap<String, Object> hashMapUserProperty = new HashMap<>();
                    hashMapUserProperty = (HashMap<String, Object>) call.arguments;
                    DATB.addUserProperty(hashMapUserProperty);
                } catch (Exception ex) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString());
                }
                break;

            case MoMagicConstant.IZ_NOTIFICATION_SOUND:
                try {
                    String soundName = (String) call.arguments;
                    DATB.setNotificationSound(soundName);
                } catch (Exception ex) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString());
                }
                break;

            case MoMagicConstant.IZ_ADD_TAGS:
                try {
                    List<String> addTagList = new ArrayList<>();
                    addTagList = (List<String>) call.arguments;
                    DATB.addTag(addTagList);
                } catch (Exception ex) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString());
                }
                break;

            case MoMagicConstant.IZ_REMOVE_TAG:
                try {
                    List<String> addTagList = new ArrayList<>();
                    addTagList = (List<String>) call.arguments;
                    DATB.removeTag(addTagList);
                } catch (Exception ex) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString());
                }
                break;

            case iZootoConstant.IZ_DEFAULT_TEMPLATE:
                try {
                    int notificationTemplate = call.argument(MoMagicConstant.IZ_DEFAULT_TEMPLATE);
                   // setCustomNotification(notificationTemplate);
                } catch (Exception ex) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString());
                }
                break;

            case iZootoConstant.IZ_DEFAULT_NOTIFICATION_BANNER:
//                try {
//                    String notificationTemplateBanner = call.argument(MoMagicConstant.IZ_DEFAULT_NOTIFICATION_BANNER);
//                    if (getBadgeIcon(context, notificationTemplateBanner) != 0) {
//                        DATB.setDefaultNotificationBanner(getBadgeIcon(context, notificationTemplateBanner));
//                    }
//                } catch (Exception ex) {
//                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString());
//                }
                break;

            case iZootoConstant.IZ_HANDLE_NOTIFICATION:
                try {
                    Object handleNotification = call.argument(MoMagicConstant.IZ_HANDLE_NOTIFICATION);
                    Map<String, String> map = (Map<String, String>) handleNotification;
                    if (map != null && !map.isEmpty()) {
                        //  DATB.iZootoHandleNotification(context, map);
                    }
                } catch (Exception ex) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString());
                }
                break;

            case iZootoConstant.IZ_RECEIVED_PAYLOAD:
                try {
                   // iZootoNotificationListener.onNotificationReceivedHybrid(notificationPayload);
                    //DATB.notificationReceivedCallback(iZootoNotificationListener);
                } catch (Exception ex) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString());
                }
                break;

            case iZootoConstant.IZ_OPEN_NOTIFICATION:
                try {
                  //  iZootoNotificationListener.onNotificationOpened(notificationOpenedData);
                   // iZooto.notificationClick(iZootoNotificationListener);
                } catch (Exception ex) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString());
                }
                break;

            case iZootoConstant.IZ_DEVICE_TOKEN:
                try {

                } catch (Exception ex) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString());
                }
                break;




            /*   navigateToSettings    */
            case iZootoConstant.IZ_NAVIGATE_SETTING:
                try {
                    DATB.navigateToSettings(activity);
                } catch (Exception ex) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString());
                }
                break;

            // Android 13 - Notification permission
            case iZootoConstant.IZ_NOTIFICATION_PERMISSION:
                try {
                    Log.e("Permission","Calling");
                    if (Build.VERSION.SDK_INT >= 33) {
                        DATB.promptForPushNotifications();
                    } else {
                        Log.e(MoMagicConstant.IZ_NOTIFICATION_PERMISSION, iZootoConstant.IZ_API_LEVEL_ERROR);
                    }
                } catch (Exception ex) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString());
                }
                break;








            default:
                result.notImplemented();
                break;
        }
    }


    private void runOnMainThread(final Runnable runnable) {
        if (Looper.getMainLooper().getThread() == Thread.currentThread())
            runnable.run();
        else {
            Handler handler = new Handler(Looper.getMainLooper());
            handler.post(runnable);
        }
    }






}
