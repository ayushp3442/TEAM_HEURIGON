package com.peertutor.controller;

import com.peertutor.dto.MySlotResponse;
import com.peertutor.dto.SlotRequest;
import com.peertutor.dto.SlotResponse;
import com.peertutor.service.SlotService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Slot controller — §6.5 endpoints 10, 11, and 12.
 */
@RestController
@RequestMapping("/api/slots")
@RequiredArgsConstructor
public class SlotController {

    private final SlotService slotService;

    @PostMapping
    @PreAuthorize("hasRole('TUTOR')")
    public ResponseEntity<SlotResponse> createSlot(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody SlotRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(slotService.create(userId, req));
    }

    @GetMapping("/mine")
    @PreAuthorize("hasRole('TUTOR')")
    public ResponseEntity<List<MySlotResponse>> getMySlots(@AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(slotService.getMySlots(userId));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('TUTOR')")
    public ResponseEntity<Void> deleteSlot(
            @AuthenticationPrincipal Long userId,
            @PathVariable Long id) {
        slotService.delete(userId, id);
        return ResponseEntity.noContent().build();
    }
}
