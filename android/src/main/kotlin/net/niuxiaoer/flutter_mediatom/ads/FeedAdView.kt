package net.niuxiaoer.flutter_mediatom.ads

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.view.ViewGroup.LayoutParams.WRAP_CONTENT
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import com.bumptech.glide.Glide
import com.yd.saas.api.AdParams
import com.yd.saas.api.mixNative.*
import com.yd.saas.common.util.Check
import com.yd.saas.config.exception.YdError
import com.yd.saas.config.utils.DeviceUtil
import com.yd.saas.ydsdk.api.YdSDK
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import net.niuxiaoer.flutter_mediatom.R
import net.niuxiaoer.flutter_mediatom.constants.ChannelName
import kotlin.math.roundToInt

class FeedAdViewFactory(private val activity: Activity, private val messenger: BinaryMessenger) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String, Any>? ?: emptyMap()
        return FeedAdView(activity, viewId, creationParams, messenger)
    }
}

class FeedAdView(
    private val activity: Activity,
    viewId: Int,
    private val args: Map<String, Any>,
    messenger: BinaryMessenger
) : PlatformView, NativeLoadListener, NativeEventListener {
    private val TAG: String = this::class.java.simpleName

    /** Flutter 通信 */
    private var methodChannel: MethodChannel

    /** 混入 Flutter 视图 */
    private var container: FrameLayout = FrameLayout(activity)

    /** 模板广告宽 px */
    private val expressAdWidth = DeviceUtil.getMobileWidth()

    /** 模板广告宽 px */
    private val expressAdHeight = (expressAdWidth * 0.28).toInt()

    /** 模板广告宽 px */
    private val acceptedImageWidth = (expressAdWidth * 0.4).roundToInt()

    /** 模板广告宽 px */
    private val acceptedImageHeight = expressAdHeight

    override fun getView(): View {
        return container
    }

    override fun dispose() {
        container.removeAllViews()
    }

    init {
        // 广告容器
        container.layoutParams = FrameLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT)
        container.clipChildren = false
        container.setBackgroundColor(Color.WHITE)

        methodChannel = MethodChannel(messenger, "${ChannelName.FEED_AD.value}/$viewId")
        loadAd()
    }

    /** Flutter 通信 */
    private fun postMessage(method: String, arguments: Map<String, Any>? = null) {
        methodChannel.invokeMethod(method, arguments)
    }

    /** 加载广告 */
    private fun loadAd() {
        // dp 单位
        val width = DeviceUtil.px2dip(expressAdWidth.toFloat())
        val height = DeviceUtil.px2dip(expressAdHeight.toFloat())
        val params = AdParams.Builder(args["slotId"] as String).apply {
            setExpressWidth(width.toFloat())
            setExpressHeight(height.toFloat())
            setExpressFullWidth()
            setExpressAutoHeight()
            setImageAcceptedWidth(acceptedImageWidth)
            setImageAcceptedHeight(acceptedImageHeight)
        }.build()
        YdSDK.loadMixNative(activity, params, this)
    }

    /** 填充模板广告 */
    private fun inflateExpressAd(nativeAd: NativeAd, nativeAdView: NativeAdView) {
        val mediaView = nativeAd.adMaterial.adMediaView ?: return
        nativeAdView.addView(mediaView, FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT))
        nativeAd.renderAdContainer(nativeAdView, null)
        val prepareInfo = NativePrepareInfo()
        prepareInfo.activity = activity
        nativeAd.prepare(prepareInfo)
    }

    /** 填充模板广告 */
    private fun inflateSelfRenderingAd(nativeAd: NativeAd, nativeAdView: NativeAdView) {
        val adView = View.inflate(activity, R.layout.feed_ad, null)
        nativeAdView.addView(adView, FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT))
        nativeAd.renderAdContainer(nativeAdView, adView)

        val title: TextView = adView.findViewById(R.id.feed_title)
        val description: TextView = adView.findViewById(R.id.feed_description)
        val image: ImageView = adView.findViewById(R.id.feed_image)
        // 图片or视频
        val mediaContainer: FrameLayout = adView.findViewById(R.id.feed_media_container)
        // 广告商Logo（穿山甲、百度Logo）
        val adLogo: ImageView = adView.findViewById(R.id.feed_ad_logo)
        val closeButton: ImageView = adView.findViewById(R.id.feed_close)
        // 点击后触发行为描述（点击下载、查看详情等）
        val action: TextView = adView.findViewById(R.id.feed_action)
        closeButton.setOnClickListener { container.removeAllViews() }

        // 填充广告素材
        val nativeMaterial = nativeAd.adMaterial
        title.text = nativeMaterial.title
        description.text = nativeMaterial.description
        action.text = nativeMaterial.callToAction?.ifBlank { null } ?: "查看详情"

        // 视频广告素材
        if (nativeMaterial.adType == NativeAdConst.AD_TYPE_VIDEO && nativeMaterial.adMediaView != null) {
            image.visibility = View.GONE
            mediaContainer.addView(
                nativeMaterial.adMediaView, ViewGroup.LayoutParams(acceptedImageWidth, MATCH_PARENT)
            )
        } else {
            val imageUrl = nativeMaterial.mainImageUrl?.ifBlank { null } ?: Check.findFirstNonNull(
                nativeMaterial.imageUrlList
            )

            if (imageUrl?.isNotEmpty() == true) {
                Glide.with(activity).load(imageUrl).into(image)
            }
        }

        // Logo 素材
        if (nativeMaterial.adLogo != null) {
            adLogo.setImageBitmap(nativeMaterial.adLogo)
        } else if (nativeMaterial.adLogoUrl.isNotEmpty()) {
            Glide.with(activity).load(nativeMaterial.adLogoUrl).into(adLogo)
        }

        val prepareInfo = NativePrepareInfo().apply {
            this.activity = activity
            closeView = closeButton
            setClickView(adView)
            setCtaView(action)
            setImageView(image)
        }
        nativeAd.prepare(prepareInfo)
    }

    // 广告加载成功
    override fun onNativeAdLoaded(nativeAd: NativeAd?) {
        Log.d(TAG, "onNativeAdLoaded isNativeExpress:${nativeAd?.isNativeExpress}")
        if (nativeAd == null) return;
        postMessage("onAdLoadSuccess")

        nativeAd.setNativeEventListener(this)
        container.removeAllViews()

        // 广告视图均添加入该视图
        val nativeAdView = NativeAdView(activity)
        container.addView(nativeAdView, FrameLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT))

        // 模板广告
        if (nativeAd.isNativeExpress) {
            inflateExpressAd(nativeAd, nativeAdView)
            return;
        }

        // 自渲染广告
        inflateSelfRenderingAd(nativeAd, nativeAdView)
    }

    // 广告加载失败
    override fun onAdFailed(error: YdError?) {
        Log.d(TAG, "onAdFailed ${error.toString()}")
        postMessage("onAdLoadFail")
    }

    // 广告展示成功
    override fun onAdImpressed(nativeAdView: NativeAdView?) {
        Log.d(TAG, "onAdImpressed")
        if (nativeAdView == null) return;
        postMessage("onAdDidShow")
        val height: Double = DeviceUtil.px2dip(nativeAdView.height.toFloat()).toDouble()
        postMessage("onAdRenderSuccess", mapOf("height" to height))
    }

    // 广告渲染失败
    override fun onAdFailed(p0: NativeAdView?, p1: YdError?) {
        Log.d(TAG, "onAdFailed")
        postMessage("onAdTerminate")
    }

    // 广告被点击
    override fun onAdClicked(p0: NativeAdView?) {
        Log.d(TAG, "onAdClicked")
        postMessage("onAdDidClick")
    }

    // 广告被关闭
    override fun onAdClose(p0: NativeAdView?) {
        Log.d(TAG, "onAdClose")
        postMessage("onAdDidClose")
    }

    override fun onAdVideoStart(p0: NativeAdView?) {}

    override fun onAdVideoEnd(p0: NativeAdView?) {}

    override fun onAdVideoProgress(p0: NativeAdView?, p1: Long) {}
}