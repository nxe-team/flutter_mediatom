package net.niuxiaoer.flutter_mediatom.views

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
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
    private val activity: Activity, viewId: Int, args: Map<String, Any>, messenger: BinaryMessenger
) : PlatformView, NativeLoadListener, NativeEventListener {
    private val TAG: String = this::class.java.simpleName
    private var methodChannel: MethodChannel
    private var container: FrameLayout = FrameLayout(activity)
    private val adContainerW = DeviceUtil.getMobileWidth() - DeviceUtil.dip2px(12F) * 2
    private val adContainerH = (adContainerW * 0.28).toInt()
    private val imageW = (adContainerW * 0.4).roundToInt()
    private val imageH = adContainerH

    override fun getView(): View {
        return container
    }

    override fun dispose() {
        container.removeAllViews()
    }

    init {
        // 广告容器
        container.layoutParams = LinearLayout.LayoutParams(
            // 宽度和父容器相同
            ViewGroup.LayoutParams.WRAP_CONTENT,
            // 高度能包裹广告视图
            ViewGroup.LayoutParams.WRAP_CONTENT
        )
        container.clipChildren = false
        container.setBackgroundColor(Color.WHITE)

        methodChannel = MethodChannel(messenger, "${ChannelName.FEED_AD.value}/$viewId")

        val width = DeviceUtil.px2dip(adContainerW.toFloat())
        val height = DeviceUtil.px2dip(adContainerH.toFloat())
        val params = AdParams.Builder(args["slotId"] as String).setExpressWidth(width.toFloat())
            .setExpressHeight(height.toFloat()).setExpressFullWidth().setExpressAutoHeight()
            .setImageAcceptedWidth(imageW).setImageAcceptedHeight(imageH).build()
        YdSDK.loadMixNative(activity, params, this)
    }

    /** Flutter 通信 */
    private fun postMessage(method: String, arguments: Map<String, Any>? = null) {
        methodChannel.invokeMethod(method, arguments)
    }

    override fun onNativeAdLoaded(nativeAd: NativeAd?) {
        Log.d(TAG, "onNativeAdLoaded")
        if (nativeAd == null) return;
        postMessage("onAdLoadSuccess")
        nativeAd.setNativeEventListener(this)
        container.removeAllViews()
        // 广告视图均添加入该视图
        val nativeAdView = NativeAdView(activity)

        container.addView(
            nativeAdView, FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT
            )
        )

        // 模板广告
        if (nativeAd.isNativeExpress) {
            Log.d(TAG, "模板广告")
            val mediaView = nativeAd.adMaterial.adMediaView
            nativeAdView.addView(
                mediaView, FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT
                )
            )
            nativeAd.renderAdContainer(nativeAdView, null)
            val prepareInfo = NativePrepareInfo()
            prepareInfo.activity = activity
            nativeAd.prepare(prepareInfo)
            return;
        }

        // 自渲染广告
        Log.d(TAG, "自渲染广告")
        val adView = View.inflate(activity, R.layout.feed_ad, null)
        nativeAdView.addView(
            adView, FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT
            )
        )
        nativeAd.renderAdContainer(nativeAdView, adView)

        val title: TextView = adView.findViewById(R.id.feed_title)
        val description: TextView = adView.findViewById(R.id.feed_description)
        val image: ImageView = adView.findViewById(R.id.feed_image)
        val mediaContainer: FrameLayout = adView.findViewById(R.id.feed_media_container)
        // 广告商Logo
        val adLogo: ImageView = adView.findViewById(R.id.feed_ad_logo)
        val closeButton: ImageView = adView.findViewById(R.id.feed_close)
        val action: TextView = adView.findViewById(R.id.feed_action)
        closeButton.setOnClickListener { container.removeAllViews() }

        // 填充广告素材
        val nativeMaterial = nativeAd.adMaterial
        title.text = nativeMaterial.title
        description.text = nativeMaterial.description
        action.text = nativeMaterial.callToAction.ifBlank { "查看详情" }

        // 视频广告素材
        if (nativeMaterial.adType == NativeAdConst.AD_TYPE_VIDEO && nativeMaterial.adMediaView != null) {
            image.visibility = View.GONE
            mediaContainer.addView(
                nativeMaterial.adMediaView,
                ViewGroup.LayoutParams(imageW, ViewGroup.LayoutParams.MATCH_PARENT)
            )
        } else {
            val imageUrl = nativeMaterial.mainImageUrl?.ifBlank { null } ?: Check.findFirstNonNull(
                nativeMaterial.imageUrlList
            )

            if (imageUrl?.isNotEmpty() == true) {
                Glide.with(activity).load(imageUrl).into(image)
            }
        }

        if (nativeMaterial.adLogo != null) {
            adLogo.setImageBitmap(nativeMaterial.adLogo)
        } else if (nativeMaterial.adLogoUrl.isNotEmpty()) {
            Glide.with(activity).load(nativeMaterial.adLogoUrl).into(adLogo)
        }

        val prepareInfo = NativePrepareInfo()
        prepareInfo.activity = activity
        prepareInfo.closeView = closeButton
        prepareInfo.setClickView(adView)
        prepareInfo.setCtaView(action)
        prepareInfo.setImageView(image)
        nativeAd.prepare(prepareInfo)
    }

    // 广告加载失败
    override fun onAdFailed(error: YdError?) {
        Log.d(TAG, "onAdFailed ${error.toString()}")
        postMessage("onAdLoadFail")
    }

    // 广告展示成功
    override fun onAdImpressed(p0: NativeAdView?) {
        Log.d(TAG, "onAdImpressed")
        if (p0 == null) return;
        postMessage("onAdDidShow")
        val height: Double = DeviceUtil.px2dip(p0.height.toFloat()).toDouble()
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