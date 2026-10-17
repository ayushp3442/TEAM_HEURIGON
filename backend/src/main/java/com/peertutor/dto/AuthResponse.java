package com.peertutor.dto;

/** Response returned by POST /api/auth/register and POST /api/auth/login — §6.2 */
public record AuthResponse(
    String token,
    UserResponse user
) {}
