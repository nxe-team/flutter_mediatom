package net.niuxiaoer.flutter_mediatom.ads

import android.app.Activity
import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import com.yd.saas.base.interfaces.AdViewSpreadListener
import com.yd.saas.base.interfaces.SpreadLoadListener
import com.yd.saas.config.exception.YdError
import com.yd.saas.ydsdk.YdSpread
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import net.niuxiaoer.flutter_mediatom.R
import net.niuxiaoer.flutter_mediatom.constants.ChannelName
import java.util.*
import kotlin.concurrent.schedule

class SplashAdActivity : AppCompatActivity(), SpreadLoadListener, AdViewSpreadListener {
    companion object {
        private lateinit var messenger: BinaryMessenger
        private var result: MethodChannel.Result? = null

        /** 启动开屏 */
        fun launch(
            activity: Activity,
            args: Map<String, Any>,
            result: MethodChannel.Result,
            messenger: BinaryMessenger
        ) {
            SplashAdActivity.result = result
            SplashAdActivity.messenger = messenger
            val splashAd = Intent(activity.applicationContext, SplashAdActivity::class.java).apply {
                putExtra("slotId", args["slotId"] as String)
                putExtra("logo", args["logo"] as String?)
                putExtra("timeout", args["timeout"] as Int?)
            }
            activity.startActivity(splashAd)
        }
    }

    private val TAG: String = this::class.java.simpleName

    /** 广告容器 */
    private lateinit var container: FrameLayout

    /** 开屏广告 */
    private lateinit var splashAd: YdSpread

    /** Flutter 通信 */
    private lateinit var methodChannel: MethodChannel

    /** 兜底关闭计时器 */
    private var fallbackTimer: TimerTask? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash_ad)
        // 设置淡入淡出
        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out)

        methodChannel = MethodChannel(messenger, ChannelName.SPLASH_AD.value)
        container = findViewById(R.id.splash_ad_container)
        loadLogo()
        loadAd()
    }

    override fun onDestroy() {
        super.onDestroy()
        fallbackTimer?.cancel()
        splashAd.destroy()
    }

    /** 结束该开屏 */
    @Synchronized
    private fun finishActivity() {
        if (isFinishing) return

        finish()
        // 渐出关闭
        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out)
    }

    /** Flutter 通信 */
    private fun postMessage(method: String, arguments: Map<String, Any>? = null) {
        methodChannel.invokeMethod(method, arguments)
    }

    /** 结束 Flutter 调用等待 */
    @Synchronized
    private fun maybeResult(isOK: Boolean) {
        result?.success(isOK)
        result = null
    }

    /** 加载logo */
    private fun loadLogo() {
        val logoResource = intent.getStringExtra("logo").takeIf {
            it != null && it.isNotEmpty()
        }?.let {
            // 与 flutter_gromore 保持一致使用 mipmap（除应用启动图标外其他资源建议放于 drawable 下）
            resources.getIdentifier(it, "mipmap", packageName)
        }

        val logoView = findViewById<ImageView>(R.id.splash_logo)
        if (logoResource == null || logoResource <= 0) {
            Log.d(TAG, "splash logo not found.")
            logoView.visibility = View.GONE
            return
        }
        logoView.setImageResource(logoResource)
    }

    /** 加载广告 */
    private fun loadAd() {
        val timeout = intent.getIntExtra("timeout", 6)
        splashAd = YdSpread.Builder(this).apply {
            key = intent.getStringExtra("slotId")
            setTimeOut(timeout)
        }.setSpreadLoadListener(this).setSpreadListener(this).build()
        splashAd.requestSpread()

        // 超时后追加1s仍未触发加载成功则自动关闭
        fallbackTimer = Timer().schedule(((timeout + 1) * 1000).toLong()) { fallback() }
    }

    /**
     * 兜底应急计划
     * 加载后无展示回调、展示后无关闭回调 -> 自动关闭活动
     * 开屏影响到用户能否使用应用！！
     */
    private fun fallback() {
        Log.d(TAG, "onAdFallback")
        if (!isFinishing) {
            runOnUiThread {
                postMessage("onAdFallback")
                finishActivity()
                maybeResult(false)
            }
        }
    }

    // 广告加载成功
    override fun onADLoaded(ad: SpreadLoadListener.SpreadAd?) {
        Log.d(TAG, "onADLoaded")
        postMessage("onAdLoadSuccess")
        ad?.show(container)
    }

    // 广告加载失败
    override fun onAdFailed(error: YdError?) {
        Log.d(TAG, "onAdFailed ${error.toString()}")
        postMessage("onAdLoadFail")
        finishActivity()
        maybeResult(false)
    }

    // 广告已展示
    override fun onAdDisplay() {
        Log.d(TAG, "onAdDisplay")
        postMessage("onAdDidShow")

        // 6妙后自动跳广告
        fallbackTimer?.cancel()
        fallbackTimer = Timer().schedule(6000) { fallback() }
    }

    // 广告被关闭
    override fun onAdClose() {
        Log.d(TAG, "onAdClose")
        postMessage("onAdDidClose")
        finishActivity()
        maybeResult(true)
    }

    // 广告被点击
    override fun onAdClick(p0: String?) {
        Log.d(TAG, "onAdClick $p0")
        postMessage("onAdDidClick")
    }
}