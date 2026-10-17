package com.peertutor.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.util.Date;

/**
 * JWT utility — jjwt 0.12 API, exactly as in Architecture.md §4.4.
 * Subject = userId (Long as String). Claim "role" = STUDENT | TUTOR (without ROLE_ prefix).
 */
@Component
public class JwtUtil {

    private static final String LOCAL_DEFAULT_SECRET = "change-this-to-a-long-random-secret-at-least-32-chars!!";

    private final SecretKey key;
    private final long expirationMs;
    private final Clock clock;

    public JwtUtil(@Value("${app.jwt.secret:}") String secret,
                   @Value("${app.jwt.expiration-ms}") long expirationMs,
                   @Value("${app.env:local}") String appEnv,
                   Clock clock) {
        String effectiveSecret = secret;
        boolean isProduction = "production".equalsIgnoreCase(appEnv);

        if (isProduction) {
            if (effectiveSecret == null || effectiveSecret.isBlank() || effectiveSecret.equals(LOCAL_DEFAULT_SECRET) || effectiveSecret.length() < 32) {
                throw new IllegalStateException("FATAL: In production environment (APP_ENV=production), JWT_SECRET must be explicitly set to a unique, random string of at least 32 characters (found insecure default or length < 32).");
            }
        } else {
            if (effectiveSecret == null || effectiveSecret.isBlank()) {
                effectiveSecret = LOCAL_DEFAULT_SECRET;
            } else if (effectiveSecret.length() < 32) {
                throw new IllegalStateException("FATAL: JWT_SECRET must be at least 32 characters long.");
            }
        }

        this.key = Keys.hmacShaKeyFor(effectiveSecret.getBytes(StandardCharsets.UTF_8));
        this.expirationMs = expirationMs;
        this.clock = clock;
    }

    public String generateToken(Long userId, String role) {
        long nowMillis = clock.millis();
        return Jwts.builder()
                .subject(String.valueOf(userId))
                .claim("role", role)
                .issuedAt(new Date(nowMillis))
                .expiration(new Date(nowMillis + expirationMs))
                .signWith(key)
                .compact();
    }

    public Claims parse(String token) {
        return Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload();
    }
}
