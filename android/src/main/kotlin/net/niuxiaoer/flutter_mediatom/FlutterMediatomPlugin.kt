package net.niuxiaoer.flutter_mediatom

import android.app.Activity
import android.content.Context
import com.yd.saas.base.interfaces.AdViewInterstitialListener
import com.yd.saas.config.exception.YdError
import com.yd.saas.ydsdk.YdInterstitial
import com.yd.saas.ydsdk.manager.YdConfig
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterMediatomPlugin */
class FlutterMediatomPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity
    private lateinit var interstitialAd: YdInterstitial

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_mediatom")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
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
        result.success(true)
    }

    /**
     * 显示插屏广告
     */
    private fun showInterstitialAd(args: Map<String, Any>, result: Result) {
        interstitialAd =
            YdInterstitial.Builder(activity).setKey(args["slotId"] as String).setWidth(600)
                .setHeight(800).setTimeOut(args["timeout"] as Int? ?: 6)
                .setInterstitialListener(object : AdViewInterstitialListener {
                    override fun onAdFailed(error: YdError?) {
                        Log.d("###", "onAdFailed ${error.toString()}")
                    }

                    override fun onAdReady() {
                        Log.d("###", "onAdReady")
                        interstitialAd.show()
                    }

                    override fun onAdDisplay() {
                        Log.d("###", "onAdDisplay")
                    }

                    override fun onAdClick(p0: String?) {
                        Log.d("###", "onAdClick $p0")
                    }

                    override fun onAdClosed() {
                        Log.d("###", "onAdClosed")
                    }
                }).build()
        interstitialAd.requestInterstitial()
        result.success(true)
    }
}
