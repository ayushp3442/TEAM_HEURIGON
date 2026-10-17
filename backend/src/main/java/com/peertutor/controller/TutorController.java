package com.peertutor.controller;

import com.peertutor.dto.SlotResponse;
import com.peertutor.dto.TutorCardResponse;
import com.peertutor.dto.TutorProfileRequest;
import com.peertutor.dto.TutorProfileResponse;
import com.peertutor.service.SlotService;
import com.peertutor.service.TutorService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Tutor controller — §6.4 endpoints 5, 6, 7, 8, and 9.
 */
@RestController
@RequestMapping("/api/tutors")
@RequiredArgsConstructor
public class TutorController {

    private final TutorService tutorService;
    private final SlotService slotService;

    @GetMapping
    public ResponseEntity<List<TutorCardResponse>> searchTutors(
            @AuthenticationPrincipal Long userId,
            @RequestParam(required = false) Long subjectId,
            @RequestParam(required = false) String mode,
            @RequestParam(required = false) String date) {
        return ResponseEntity.ok(tutorService.searchTutors(userId, subjectId, mode, date));
    }

    @GetMapping("/me")
    @PreAuthorize("hasRole('TUTOR')")
    public ResponseEntity<TutorProfileResponse> getMyProfile(@AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(tutorService.getMyProfile(userId));
    }

    @PutMapping("/me")
    @PreAuthorize("hasRole('TUTOR')")
    public ResponseEntity<TutorProfileResponse> updateMyProfile(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody TutorProfileRequest req) {
        return ResponseEntity.ok(tutorService.updateProfile(userId, req));
    }

    @GetMapping("/{id}")
    public ResponseEntity<TutorProfileResponse> getProfileById(@PathVariable Long id) {
        return ResponseEntity.ok(tutorService.getProfileById(id));
    }

    @GetMapping("/{id}/slots")
    public ResponseEntity<List<SlotResponse>> getTutorSlots(@PathVariable Long id) {
        return ResponseEntity.ok(slotService.getOpenFutureSlots(id));
    }
}
