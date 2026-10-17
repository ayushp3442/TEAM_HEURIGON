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

    private final SecretKey key;
    private final long expirationMs;
    private final Clock clock;

    public JwtUtil(@Value("${app.jwt.secret}") String secret,
                   @Value("${app.jwt.expiration-ms}") long expirationMs,
                   Clock clock) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
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
