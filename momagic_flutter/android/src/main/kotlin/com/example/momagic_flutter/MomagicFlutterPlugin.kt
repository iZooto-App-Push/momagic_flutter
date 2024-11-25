package com.example.momagic_flutter

import android.app.Activity
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.google.gson.Gson
import com.momagic.AppConstant
import com.momagic.DATB
import com.momagic.NotificationHelperListener
import com.momagic.NotificationWebViewListener
import com.momagic.Payload
import com.momagic.PushTemplate
import com.momagic.TokenReceivedListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** MomagicFlutterPlugin */
class MomagicFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private var notificationOpenedData: String? = null
    private var notificationToken: String? = null
    private var notificationWebView: String? = null
    private var notificationPayload: String? = null

    companion object {
        private const val TAG = "MOMAGIC_FLUTTER"
    }

    // ActivityAware methods
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        this.activity = null
    }

    // Flutter plugin binding
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        try {
            context = flutterPluginBinding.applicationContext
            channel = MethodChannel(flutterPluginBinding.binaryMessenger, MoMagicConstant.IZ_PLUGIN_NAME)
            channel.setMethodCallHandler(this)
        } catch (ex: Exception) {
            Log.d(TAG, ex.toString())
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        try {
            channel.setMethodCallHandler(null)
        } catch (ex: Exception) {
            Log.d(TAG, ex.toString())
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            val moMagicNotificationListener = MoMagicNotificationListener()

            when (call.method) {

                MoMagicConstant.IZ_ANDROID_INIT -> {
                    try {
                        DATB.initialize(context)
                            .setTokenReceivedListener(moMagicNotificationListener)
                            .setNotificationReceiveListener(moMagicNotificationListener)
                            .setLandingURLListener(moMagicNotificationListener)
                            .build()
                    } catch (ex: Exception) {
                        Log.e(TAG, ex.toString())
                    }
                }

                MoMagicConstant.IZ_SET_SUBSCRIPTION -> {
                    try {
                        val setSubscription = call.arguments as Boolean
                        DATB.setSubscription(setSubscription)
                    } catch (ex: Exception) {
                        Log.e(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
                    }
                }

                MoMagicConstant.IZ_PLUGIN_SUBSCRIBER_ID -> {
                    try {
                        val subscriberId = call.arguments as String
                        DATB.setSubscriberID(subscriberId)
                    } catch (ex: Exception) {
                        Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
                    }
                }

                MoMagicConstant.IZ_FIREBASE_ANALYTICS -> {
                    try {
                        val trackFirebaseAnalytics = call.arguments as Boolean
                        DATB.setFirebaseAnalytics(trackFirebaseAnalytics)
                    } catch (ex: Exception) {
                        Log.e(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
                    }
                }

                MoMagicConstant.IZ_ADD_EVENTS -> {
                    try {
                        val eventName = call.argument<String>(MoMagicConstant.IZ_EVENT_NAME)
                        val hashMapEvent = call.argument<HashMap<String, Any>>(MoMagicConstant.IZ_EVENT_VALUE)
                        DATB.addEvent(eventName, hashMapEvent)
                    } catch (ex: Exception) {
                        Log.e(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
                    }
                }

                MoMagicConstant.IZ_ADD_PROPERTIES -> {
                    try {
                        val hashMapUserProperty = call.argument<HashMap<String, Any>>(MoMagicConstant.IZ_ADD_PROPERTIES)
                        DATB.addUserProperty(hashMapUserProperty)
                    } catch (ex: Exception) {
                        Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
                    }
                }

                MoMagicConstant.IZ_NOTIFICATION_SOUND -> {
                    try {
                        val soundName = call.arguments as String
                        DATB.setNotificationSound(soundName)
                    } catch (ex: Exception) {
                        Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
                    }
                }

                MoMagicConstant.IZ_ADD_TAGS -> {
                    try {
                        val addTagList = call.arguments<List<String>>()
                        DATB.addTag(addTagList)
                    } catch (ex: Exception) {
                        Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
                    }
                }

                MoMagicConstant.IZ_REMOVE_TAG -> {
                    try {
                        val addTagList = call.arguments<List<String>>()
                        DATB.removeTag(addTagList)
                    } catch (ex: Exception) {
                        Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
                    }
                }

                MoMagicConstant.IZ_DEFAULT_TEMPLATE -> {
                    try {
                        val notificationTemplate = call.argument<Int>(MoMagicConstant.IZ_DEFAULT_TEMPLATE) ?: 0
                        setCustomNotification(notificationTemplate)
                    } catch (ex: Exception) {
                        Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
                    }
                }

                MoMagicConstant.IZ_DEFAULT_NOTIFICATION_BANNER -> {
                    try {
                        val notificationTemplateBanner = call.argument<String>(MoMagicConstant.IZ_DEFAULT_NOTIFICATION_BANNER)
                        notificationTemplateBanner?.let {
                            if (getBadgeIcon(context, it) != 0) {
                                DATB.setDefaultNotificationBanner(getBadgeIcon(context, it))
                            }
                        }
                    } catch (ex: Exception) {
                        Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
                    }
                }

                MoMagicConstant.IZ_RECEIVED_PAYLOAD -> {
                    try {

//                        Log.d(TAG, "receivedPayload $notificationPayload")

//                        moMagicNotificationListener.onNotificationReceivedHybrid(notificationPayload)
//                        DATB.notificationReceivedCallback(iZootoNotificationListener)
                    } catch (ex: Exception) {
                        Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
                    }
                }

                MoMagicConstant.IZ_OPEN_NOTIFICATION -> {
                    try {
                        moMagicNotificationListener.onNotificationOpened(notificationOpenedData)

//                        Log.d(TAG, "openNotification $notificationOpenedData")

//                        DATB.notificationClick(iZootoNotificationListener)
                    } catch (ex: Exception) {
                        Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
                    }
                }

                MoMagicConstant.IZ_DEVICE_TOKEN -> {
                    try {
                        moMagicNotificationListener.onTokenReceived(notificationToken)
                    } catch (ex: Exception) {
                        Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
                    }
                }

                MoMagicConstant.IZ_HANDLE_WEB_VIEW -> {
//                    if (!preferenceUtil.getBoolean(AppConstant.IZ_DEFAULT_WEB_VIEW)) {
                        try {

//                            Log.d(TAG, "notificationWebView $notificationWebView")

//                            DATB.onWebView(notificationWebView)
//                            DATB.notificationWebView(iZootoNotificationListener)
                        } catch (ex: Exception) {
                            Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
                        }
//                    }
                }

                MoMagicConstant.IZ_CHANNEL_NAME -> {
                    try {
                        val channelName = call.arguments as String
                        DATB.setNotificationChannelName(channelName)
                    } catch (ex: Exception) {
                        Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
                    }
                }

                MoMagicConstant.IZ_NAVIGATE_SETTING -> {
                    try {
                        DATB.navigateToSettings(activity)
                    } catch (ex: Exception) {
                        Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
                    }
                }

                MoMagicConstant.IZ_NOTIFICATION_PERMISSION -> {
                    try {
                        if (Build.VERSION.SDK_INT >= 33) {
                            DATB.promptForPushNotifications()
                        } else {
                            Log.d(MoMagicConstant.IZ_PLUGIN_EXCEPTION, MoMagicConstant.IZ_API_LEVEL_ERROR)
                        }
                    } catch (ex: Exception) {
                        Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }

        } catch (ex: Exception) {
            Log.e(TAG, ex.message.toString())
        }
    }

    private fun runOnMainThread(runnable: Runnable) {
        try {
            if (Looper.getMainLooper().thread == Thread.currentThread()) {
                runnable.run()
            } else {
                Handler(Looper.getMainLooper()).post(runnable)
            }
        } catch (ex: Exception) {
            Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
        }
    }

    fun invokeMethodOnUiThread(methodName: String, map: String) {
        try {
            runOnMainThread {
                channel.invokeMethod(methodName, map)
            }
        } catch (ex: Exception) {
            Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
        }
    }

    private fun setCustomNotification(index: Int) {
        try {
            when (index) {
                2 -> DATB.setDefaultTemplate(PushTemplate.TEXT_OVERLAY)
                3 -> DATB.setDefaultTemplate(PushTemplate.DEVICE_NOTIFICATION_OVERLAY)
                else -> DATB.setDefaultTemplate(PushTemplate.DEFAULT)
            }
        } catch (ex: Exception) {
            Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, ex.toString())
        }
    }

    private fun getBadgeIcon(context: Context, setBadgeIcon: String): Int {
        var badgeIcon = 0
        try {
            val drawableId = context.resources.getIdentifier(setBadgeIcon, "drawable", context.packageName)
            if (drawableId != 0) {
                badgeIcon = drawableId
            } else {
                val mipmapId = context.resources.getIdentifier(setBadgeIcon, "mipmap", context.packageName)
                if (mipmapId != 0) {
                    badgeIcon = mipmapId
                }
            }
        } catch (e: Exception) {
            Log.v(AppConstant.APP_NAME_TAG, e.toString())
        }
        return badgeIcon
    }


    // MoMagic Listeners Implementation
    private inner class MoMagicNotificationListener : NotificationHelperListener, NotificationWebViewListener, TokenReceivedListener {

        override fun onNotificationReceived(payload: Payload?) {
//            Log.d(TAG, "onNotificationReceived $payload")

            if (payload != null) {
                try {
                    val jsonPayload = Gson().toJson(payload)
                    invokeMethodOnUiThread(MoMagicConstant.IZ_RECEIVED_PAYLOAD, jsonPayload)
                } catch (e: Exception) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, e.toString())
                }
            }
        }

        override fun onNotificationOpened(data: String?) {
//            Log.d(TAG, "onNotificationOpened $data")

            notificationOpenedData = data
            if (data != null) {
                try {
                    invokeMethodOnUiThread(MoMagicConstant.IZ_OPEN_NOTIFICATION, data)
                } catch (e: Exception) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, e.toString())
                }
            }
        }

        override fun onWebView(landingUrl: String?) {
//            Log.d(TAG, "onWebView $landingUrl")

            notificationWebView = landingUrl
            if (landingUrl != null) {
                try {
                    invokeMethodOnUiThread(MoMagicConstant.IZ_HANDLE_WEB_VIEW, landingUrl)
                } catch (e: java.lang.Exception) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, e.toString())
                }
            }
        }

        override fun onTokenReceived(token: String?) {
//            Log.d(TAG, "onTokenReceived $token")

            notificationToken = token
            if (token != null) {
                try {
                    invokeMethodOnUiThread(MoMagicConstant.IZ_DEVICE_TOKEN, token)
                } catch (e: java.lang.Exception) {
                    Log.v(MoMagicConstant.IZ_PLUGIN_EXCEPTION, e.toString())
                }
            }
        }
    }

}
