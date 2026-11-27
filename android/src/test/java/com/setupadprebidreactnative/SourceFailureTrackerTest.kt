package com.setupadprebidreactnative

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import org.prebid.mobile.api.data.SdkType

class SourceFailureTrackerTest {
  @Test fun oneSourceFailureCanBeFollowedBySuccess() {
    val tracker = SourceFailureTracker()
    assertNull(tracker.record(SdkType.PREBID, "no bid"))
    tracker.reset()
    assertNull(tracker.record(SdkType.GAM, "no fill"))
  }

  @Test fun bothSourceFailuresProduceOneFinalError() {
    val tracker = SourceFailureTracker()
    assertNull(tracker.record(SdkType.PREBID, "no bid"))
    assertEquals("no bid; no fill", tracker.record(SdkType.GAM, "no fill"))
    assertNull(tracker.record(SdkType.PREBID, "next cycle"))
  }

  @Test fun unlabelledFailureIsAlreadyFinal() {
    val tracker = SourceFailureTracker()
    assertEquals("loader error", tracker.record(null, "loader error"))
  }
}
