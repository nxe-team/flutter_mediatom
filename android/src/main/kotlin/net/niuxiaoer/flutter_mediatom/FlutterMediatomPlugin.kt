package net.niuxiaoer.flutter_mediatom

import android.app.Activity
import android.content.Context
import android.content.Intent
import com.yd.saas.ydsdk.manager.YdConfig
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import net.niuxiaoer.flutter_mediatom.ads.InterstitialAd
import net.niuxiaoer.flutter_mediatom.constants.ChannelName
import net.niuxiaoer.flutter_mediatom.ads.FeedAdViewFactory
import net.niuxiaoer.flutter_mediatom.ads.SplashAdActivity

/** FlutterMediatomPlugin */
class FlutterMediatomPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity

    /** 用于 Flutter 通信  */
    private lateinit var messenger: BinaryMessenger

    private lateinit var flutterBinding: FlutterPlugin.FlutterPluginBinding

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterBinding = flutterPluginBinding
        context = flutterPluginBinding.applicationContext
        messenger = flutterPluginBinding.binaryMessenger
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, ChannelName.PLUGIN.value)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity

        // 注册信息流广告 PlatformView
        flutterBinding.platformViewRegistry.registerViewFactory(
            ChannelName.FEED_AD.value, FeedAdViewFactory(activity, flutterBinding.binaryMessenger)
        )
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val args: Map<String, Any> = call.arguments<Map<String, Any>>() ?: emptyMap()
        when (call.method) {
            "initSDK" -> initSDK(args, result)
            "showSplashAd" -> showSplashAd(args, result)
            "showInterstitialAd" -> showInterstitialAd(args, result)
            else -> result.notImplemented()
        }
    }

    /**
     * 初始化SDK
     */
    private fun initSDK(args: Map<String, Any>, result: Result) {
        YdConfig.getInstance().init(context, args["appId"] as String, "", true)
        result.success(true)
    }

    /**
     * 显示开屏广告
     */
    private fun showSplashAd(args: Map<String, Any>, result: Result) {
        SplashAdActivity.launch(activity, args, result, messenger)
    }

    /**
     * 显示插屏广告
     */
    private fun showInterstitialAd(args: Map<String, Any>, result: Result) {
        InterstitialAd.launch(activity, args, result, messenger)
    }
}
