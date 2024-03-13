package net.niuxiaoer.flutter_mediatom.ads

import android.app.Activity
import com.yd.saas.base.interfaces.AdViewInterstitialListener
import com.yd.saas.config.exception.YdError
import com.yd.saas.ydsdk.YdInterstitial
import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import net.niuxiaoer.flutter_mediatom.constants.ChannelName
import java.util.*
import kotlin.concurrent.schedule

class InterstitialAd(
    private val activity: Activity,
    args: Map<String, Any>,
    private val loadedResult: MethodChannel.Result,
    messenger: BinaryMessenger
) : AdViewInterstitialListener {
    private val TAG: String = this::class.java.simpleName

    /** Flutter 通信 */
    private val methodChannel: MethodChannel

    // 已经返回结果给 Flutter，阻止多次调用 result
    private var isFulfilledForLoading: Boolean = false

    // 已经返回结果给 Flutter，阻止多次调用 result
    private var isFulfilledForShowing: Boolean = false

    /** 插屏广告 */
    private val interstitialAd: YdInterstitial

    /** 显示结果回调 */
    private var shownResult: MethodChannel.Result? = null

    /** 显示结果回调 */
    private var shownCallback: (() -> Unit)? = null

    /** 兜底关闭计时器 */
    private val fallbackTimer: Timer = Timer()

    init {
        methodChannel = MethodChannel(messenger, ChannelName.INTERSTITIAL_AD.value)
        val timeout = args["timeout"] as Int? ?: 6
        // 期望宽高使用Demo值，实际加载时会根据用户设备适配
        interstitialAd = YdInterstitial.Builder(activity).apply {
            key = args["slotId"] as String
            width = 600
            height = 800
            setTimeOut(timeout)
        }.setInterstitialListener(this).build()
        interstitialAd.requestInterstitial()

        // 超时后追加1s仍未触发加载成功则自动关闭
        fallbackTimer.schedule(((timeout + 1) * 1000).toLong()) { fallback() }
    }

    /** 显示插屏 */
    fun show(activity: Activity, result: MethodChannel.Result, callback: () -> Unit) {
        if (!interstitialAd.isReady) return;
        interstitialAd.show(activity);
        shownResult = result
        shownCallback = callback
    }

    /**
     * 兜底应急计划
     * 加载后无加载回调 -> 结束调用
     */
    private fun fallback() {
        Log.d(TAG, "onAdFallback")
        activity.runOnUiThread {
            maybeResultForLoading(false)
        }
    }

    /** Flutter 通信 */
    private fun postMessage(method: String, arguments: Map<String, Any>? = null) {
        methodChannel.invokeMethod(method, arguments)
    }

    /** 结束 Flutter 加载插屏调用等待 */
    @Synchronized
    private fun maybeResultForLoading(isOK: Boolean) {
        if (isFulfilledForLoading) return;
        isFulfilledForLoading = true
        loadedResult.success(isOK)
    }

    /** 结束 Flutter 显示插屏调用等待 */
    @Synchronized
    private fun maybeResultShowing(isOK: Boolean) {
        if (isFulfilledForShowing) return;
        isFulfilledForShowing = true
        shownResult?.success(isOK)
        interstitialAd.destroy()
        shownCallback?.let { it() }
    }

    // 广告加载成功
    override fun onAdReady() {
        Log.d(TAG, "onAdReady")
        maybeResultForLoading(true)
        fallbackTimer.cancel()
    }

    // 广告加载失败
    override fun onAdFailed(error: YdError?) {
        Log.d(TAG, "onAdFailed ${error.toString()}")
        maybeResultForLoading(false)
        fallbackTimer.cancel()
    }

    // 广告已展示
    override fun onAdDisplay() {
        Log.d(TAG, "onAdDisplay")
        postMessage("onAdDidShow")
    }

    // 广告被点击
    override fun onAdClick(p0: String?) {
        Log.d(TAG, "onAdClick $p0")
        postMessage("onAdDidClick")
    }

    // 广告被关闭
    override fun onAdClosed() {
        Log.d(TAG, "onAdClosed")
        postMessage("onAdDidClose")
        maybeResultShowing(true)
    }
}