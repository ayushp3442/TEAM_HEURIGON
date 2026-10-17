package com.peertutor.dto;

import com.peertutor.enums.Role;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/** POST /auth/register request body — §6.2 endpoint 1 */
public record RegisterRequest(
    @NotBlank(message = "name is required")
    String name,

    @NotBlank(message = "email is required")
    @Email(message = "email must be valid")
    String email,

    @NotBlank(message = "password is required")
    @Size(min = 6, message = "password must be at least 6 characters")
    String password,

    @NotNull(message = "role is required")
    Role role
) {}
