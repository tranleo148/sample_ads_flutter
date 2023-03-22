package com.sample.ads.flutter

import android.content.Context
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory


internal class NativeAdFactoryLanguageSelection(
    private val context: Context,
    private val layoutType: Int
) :
    NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>?
    ): NativeAdView {
        val layoutT = when (layoutType) {
            0 -> R.layout.my_native_ad
            1 -> R.layout.my_native_ad_medium
            2 -> R.layout.my_native_ad_small
            else -> R.layout.my_native_ad
        }
        val nativeAdView = LayoutInflater.from(context).inflate(
            layoutT,
            null
        ) as NativeAdView
        val primaryView = nativeAdView.findViewById<View>(R.id.primary) as TextView
        val secondaryView = nativeAdView.findViewById<View>(R.id.secondary) as TextView
        val tertiaryView = nativeAdView.findViewById<View>(R.id.body) as TextView

        val ratingBar = nativeAdView.findViewById<View>(R.id.rating_bar) as RatingBar
        ratingBar.isEnabled = false

        val callToActionView = nativeAdView.findViewById<View>(R.id.cta) as Button
        val iconView = nativeAdView.findViewById<View>(R.id.icon) as ImageView
        val mediaView = nativeAdView.findViewById<View>(R.id.media_view) as MediaView
        val background = nativeAdView.findViewById<View>(R.id.background) as ConstraintLayout

        val store = nativeAd.store
        val advertiser = nativeAd.advertiser
        val headline = nativeAd.headline
        val body = nativeAd.body
        val cta = nativeAd.callToAction
        val starRating = nativeAd.starRating
        val icon = nativeAd.icon

        nativeAdView.callToActionView = callToActionView
        nativeAdView.headlineView = primaryView
        nativeAdView.mediaView = mediaView
        secondaryView.visibility = View.VISIBLE
        val secondaryText: String? = if (adHasOnlyStore(nativeAd)) {
            nativeAdView.storeView = secondaryView
            store
        } else if (!TextUtils.isEmpty(advertiser)) {
            nativeAdView.advertiserView = secondaryView
            advertiser
        } else {
            ""
        }

        primaryView.text = headline
        callToActionView.text = cta

        //  Set the secondary view to be the star rating if available.
        if (starRating != null && starRating > 0) {
            secondaryView.visibility = View.GONE
            //ratingBar.visibility = View.VISIBLE
            ratingBar.rating = starRating.toFloat()
            nativeAdView.starRatingView = ratingBar
        } else {
            secondaryView.text = secondaryText
            secondaryView.visibility = View.VISIBLE
            //ratingBar.visibility = View.GONE
        }

        if (icon != null) {
            iconView.visibility = View.VISIBLE
            iconView.setImageDrawable(icon.drawable)
        } else {
            iconView.visibility = View.GONE
        }

        tertiaryView.text = body
        nativeAdView.bodyView = tertiaryView

        nativeAdView.setNativeAd(nativeAd)
        return nativeAdView
    }


    private fun adHasOnlyStore(nativeAd: NativeAd): Boolean {
        val store = nativeAd.store
        val advertiser = nativeAd.advertiser
        return !TextUtils.isEmpty(store) && TextUtils.isEmpty(advertiser)
    }
}