package com.peertutor.util;

import java.time.Clock;
import java.time.ZoneId;

/**
 * Holder for the application Clock, ensuring entity lifecycle methods (@PrePersist)
 * use the configured campus time zone.
 */
public final class ClockHolder {

    private static volatile Clock clock = Clock.system(ZoneId.of("Asia/Kolkata"));

    private ClockHolder() {}

    public static void setClock(Clock newClock) {
        if (newClock != null) {
            clock = newClock;
        }
    }

    public static Clock getClock() {
        return clock;
    }
}
