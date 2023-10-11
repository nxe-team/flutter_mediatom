package net.niuxiaoer.flutter_mediatom.views

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
import io.flutter.plugin.common.MethodChannel
import net.niuxiaoer.flutter_mediatom.FlutterMediatomPlugin
import net.niuxiaoer.flutter_mediatom.R
import net.niuxiaoer.flutter_mediatom.constants.ChannelName

class SplashAdActivity : AppCompatActivity(), SpreadLoadListener, AdViewSpreadListener {
    private val TAG: String = this::class.java.simpleName

    /** 广告容器 */
    private lateinit var container: FrameLayout

    /** 开屏广告 */
    private lateinit var splashAd: YdSpread

    /** Flutter 通信 */
    private lateinit var methodChannel: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash_ad)
        // 设置淡入淡出
        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out)

        methodChannel = MethodChannel(FlutterMediatomPlugin.messenger, ChannelName.SPLASH_AD.value)
        container = findViewById(R.id.splash_ad_container)
        loadLogo()
        loadAd()
    }
    //   TODO: VoidCallback? onAdFallback,

    /** Flutter 通信 */
    private fun postMessage(method: String, arguments: Map<String, Any>? = null) {
        methodChannel.invokeMethod(method, arguments)
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
        splashAd = YdSpread.Builder(this).setKey(intent.getStringExtra("slotId"))
            .setTimeOut(intent.getIntExtra("timeout", 6))
            .setSpreadLoadListener(this).setSpreadListener(this).build()
        splashAd.requestSpread()
    }

    /** 结束该开屏活动 */
    private fun finishActivity() {
        finish()
        // 渐出关闭
        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out)
    }

    override fun onADLoaded(ad: SpreadLoadListener.SpreadAd?) {
        ad?.show(container)
        postMessage("onAdLoadSuccess")
    }

    override fun onAdFailed(error: YdError?) {
        Log.d("###", "onAdFailed ${error.toString()}")
        postMessage("onAdLoadFail")
        finishActivity()
        FlutterMediatomPlugin.result?.success(false)
        FlutterMediatomPlugin.result = null
    }

    override fun onAdDisplay() {
        Log.d("###", "onAdDisplay")
        postMessage("onAdDidShow")
    }

    override fun onAdClose() {
        Log.d("###", "onAdClose")
        postMessage("onAdDidClose")
        finishActivity()
        FlutterMediatomPlugin.result?.success(true)
        FlutterMediatomPlugin.result = null
    }

    override fun onAdClick(p0: String?) {
        Log.d("###", "onAdClick $p0")
        postMessage("onAdDidClick")
    }
}