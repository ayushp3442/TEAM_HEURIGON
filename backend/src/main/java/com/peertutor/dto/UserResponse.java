package com.peertutor.dto;

import com.peertutor.entity.User;
import com.peertutor.enums.Role;

/** User summary returned in auth responses — §6.2 */
public record UserResponse(
    Long id,
    String name,
    String email,
    Role role
) {
    public static UserResponse from(User user) {
        return new UserResponse(
            user.getId(),
            user.getName(),
            user.getEmail(),
            user.getRole()
        );
    }
}
