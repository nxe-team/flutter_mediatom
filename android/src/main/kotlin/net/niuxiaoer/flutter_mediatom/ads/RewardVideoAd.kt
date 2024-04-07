package net.niuxiaoer.flutter_mediatom.ads

import android.app.Activity
import android.util.Log
import com.yd.saas.base.interfaces.AdViewVideoListener
import com.yd.saas.config.exception.YdError
import com.yd.saas.ydsdk.YdVideo
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import net.niuxiaoer.flutter_mediatom.constants.ChannelName

class RewardVideoAd(
    activity: Activity,
    args: Map<String, Any>,
    private val result: MethodChannel.Result,
    messenger: BinaryMessenger
) : AdViewVideoListener {
    companion object {
        /** 启动激励视频 */
        fun launch(
            activity: Activity,
            args: Map<String, Any>,
            result: MethodChannel.Result,
            messenger: BinaryMessenger
        ) {
            RewardVideoAd(activity, args, result, messenger);
        }
    }

    private val TAG: String = this::class.java.simpleName

    /** Flutter 通信 */
    private val methodChannel: MethodChannel

    /** 视频广告 */
    private val videoAd: YdVideo

    /** 已经返回结果给 Flutter，阻止多次调用 result */
    private var isFulfilled: Boolean = false

    init {
        methodChannel = MethodChannel(messenger, ChannelName.REWARD_VIDEO.value)
        videoAd = YdVideo.Builder(activity).apply {
            key = args["slotId"] as String
            setVideoListener(this@RewardVideoAd)
        }.build()
        videoAd.requestRewardVideo()
    }

    /** Flutter 通信 */
    private fun postMessage(method: String, arguments: Map<String, Any>? = null) {
        methodChannel.invokeMethod(method, arguments)
    }

    /** 结束 Flutter 加载插屏调用等待 */
    @Synchronized
    private fun maybeResult(isOK: Boolean) {
        if (isFulfilled) return;
        isFulfilled = true
        result.success(isOK)
    }

    // 广告加载完成
    override fun onVideoPrepared() {
        Log.d(TAG, "onVideoPrepared")
        postMessage("onAdLoadSuccess")
        if (!videoAd.isReady) {
            maybeResult(false)
            return;
        }
        videoAd.show();
    }

    // 广告加载失败
    override fun onAdFailed(error: YdError?) {
        Log.d(TAG, "onAdFailed")
        postMessage("onAdLoadFail")
        maybeResult(false)
    }

    // 广告展示
    override fun onAdShow() {
        Log.d(TAG, "onAdShow")
        postMessage("onAdDidShow")
    }

    // 广告关闭
    override fun onAdClose() {
        Log.d(TAG, "onAdClose")
        postMessage("onAdDidClose")
        maybeResult(true)
    }

    // 广告播放完成可奖励
    override fun onVideoReward(p0: Double) {
        Log.d(TAG, "onVideoReward")
        postMessage("onVideoReward")
    }

    // 广告播放完成
    override fun onVideoCompleted() {
        Log.d(TAG, "onVideoCompleted")
        postMessage("onVideoCompleted")
    }

    // 广告被点击
    override fun onAdClick(p0: String?) {
        Log.d(TAG, "onAdClick")
        postMessage("onAdDidClick")
    }

    // 广告被跳过
    override fun onSkipVideo() {
        Log.d(TAG, "onSkipVideo")
        postMessage("onSkipVideo")
    }
}