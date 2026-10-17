package com.peertutor.service;

import com.peertutor.dto.AuthResponse;
import com.peertutor.dto.LoginRequest;
import com.peertutor.dto.MeResponse;
import com.peertutor.dto.RegisterRequest;
import com.peertutor.dto.UserResponse;
import com.peertutor.entity.User;
import com.peertutor.exception.ApiException;
import com.peertutor.repository.TutorProfileRepository;
import com.peertutor.repository.UserRepository;
import com.peertutor.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final TutorProfileRepository tutorProfileRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    @Transactional
    public AuthResponse register(RegisterRequest req) {
        String email = req.email().trim();
        if (userRepository.existsByEmail(email)) {
            throw new ApiException(409, "Email already registered");
        }

        User user = User.builder()
                .name(req.name().trim())
                .email(email)
                .passwordHash(passwordEncoder.encode(req.password()))
                .role(req.role())
                .build();

        user = userRepository.save(user);

        String token = jwtUtil.generateToken(user.getId(), user.getRole().name());
        return new AuthResponse(token, UserResponse.from(user));
    }

    public AuthResponse login(LoginRequest req) {
        String email = req.email().trim();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(401, "Invalid email or password"));

        if (!passwordEncoder.matches(req.password(), user.getPasswordHash())) {
            throw new ApiException(401, "Invalid email or password");
        }

        String token = jwtUtil.generateToken(user.getId(), user.getRole().name());
        return new AuthResponse(token, UserResponse.from(user));
    }

    public MeResponse me(Long userId) {
        if (userId == null) {
            throw new ApiException(401, "Authentication required");
        }
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(404, "User not found"));

        boolean hasTutorProfile = tutorProfileRepository.findByUserId(userId).isPresent();
        return MeResponse.from(user, hasTutorProfile);
    }
}
