package com.setupadprebidreactnative

import org.prebid.mobile.api.data.SdkType

/** Tracks failures of the two configured sources in one load cycle. */
internal class SourceFailureTracker {
  private val failures = mutableMapOf<SdkType, String>()

  fun reset() = failures.clear()

  /** Returns an error only when no source can fill the ad. */
  fun record(sdk: SdkType?, error: String): String? {
    if (sdk == null) {
      reset()
      return error
    }
    failures[sdk] = error
    if (!failures.containsKey(SdkType.PREBID) || !failures.containsKey(SdkType.GAM)) return null
    val finalError = failures.values.joinToString("; ")
    reset()
    return finalError
  }
}
