package com.peertutor.dto;

import com.peertutor.entity.User;
import com.peertutor.enums.Role;

/** Response returned by GET /api/auth/me — §6.2 endpoint 3 */
public record MeResponse(
    Long id,
    String name,
    String email,
    Role role,
    boolean hasTutorProfile
) {
    public static MeResponse from(User user, boolean hasTutorProfile) {
        return new MeResponse(
            user.getId(),
            user.getName(),
            user.getEmail(),
            user.getRole(),
            hasTutorProfile
        );
    }
}
