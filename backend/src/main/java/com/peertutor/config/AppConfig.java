package com.peertutor.config;

import com.peertutor.util.ClockHolder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Clock;
import java.time.ZoneId;

@Configuration
public class AppConfig {

    @Value("${app.time-zone:Asia/Kolkata}")
    private String appTimeZone;

    @Bean
    public Clock clock() {
        Clock c = Clock.system(ZoneId.of(appTimeZone));
        ClockHolder.setClock(c);
        return c;
    }
}
