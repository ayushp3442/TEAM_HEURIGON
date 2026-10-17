package com.peertutor.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Clock;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Health-check endpoint — GET /api/health → {"status":"UP","timeZone":"...","serverTime":"..."}.
 * No authentication required.
 */
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class HealthController {

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");

    private final Clock clock;

    @Value("${app.time-zone:Asia/Kolkata}")
    private String timeZone;

    @GetMapping("/health")
    public Map<String, Object> health() {
        Map<String, Object> resp = new LinkedHashMap<>();
        resp.put("status", "UP");
        resp.put("timeZone", timeZone);
        resp.put("serverTime", LocalDateTime.now(clock).format(FMT));
        return resp;
    }
}
