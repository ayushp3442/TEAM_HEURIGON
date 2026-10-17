package com.peertutor.controller;

import com.peertutor.dto.CreateSessionRequest;
import com.peertutor.dto.RequestResponse;
import com.peertutor.dto.UpdateStatusRequest;
import com.peertutor.enums.RequestStatus;
import com.peertutor.service.RequestService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Session request endpoints — Architecture.md §6.6 endpoints 13 to 17.
 */
@RestController
@RequestMapping("/api/requests")
@RequiredArgsConstructor
public class RequestController {

    private final RequestService requestService;
    private final com.peertutor.service.ChatService chatService;

    /** 13. POST /api/requests (STUDENT) */
    @PostMapping
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<RequestResponse> createRequest(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody CreateSessionRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(requestService.create(userId, req));
    }

    /** 14. GET /api/requests/outgoing (STUDENT; optional ?status=; newest first) */
    @GetMapping("/outgoing")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<List<RequestResponse>> getOutgoing(
            @AuthenticationPrincipal Long userId,
            @RequestParam(required = false) RequestStatus status) {
        return ResponseEntity.ok(requestService.listOutgoing(userId, status));
    }

    /** 15. PATCH /api/requests/{id}/cancel (STUDENT who owns it; only PENDING) */
    @PatchMapping("/{id}/cancel")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<RequestResponse> cancelRequest(
            @AuthenticationPrincipal Long userId,
            @PathVariable Long id) {
        return ResponseEntity.ok(requestService.cancel(userId, id));
    }

    /** 16. GET /api/requests/incoming (TUTOR; optional ?status=; newest first) */
    @GetMapping("/incoming")
    @PreAuthorize("hasRole('TUTOR')")
    public ResponseEntity<List<RequestResponse>> getIncoming(
            @AuthenticationPrincipal Long userId,
            @RequestParam(required = false) RequestStatus status) {
        return ResponseEntity.ok(requestService.listIncoming(userId, status));
    }

    /** 17. PATCH /api/requests/{id}/status (TUTOR who owns it; body {"status":"ACCEPTED"|"DECLINED"}) */
    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('TUTOR')")
    public ResponseEntity<RequestResponse> updateStatus(
            @AuthenticationPrincipal Long userId,
            @PathVariable Long id,
            @Valid @RequestBody UpdateStatusRequest req) {
        return ResponseEntity.ok(requestService.updateStatus(userId, id, req.status()));
    }

    /** 19. GET /api/requests/{id}/messages?afterId=0 */
    @GetMapping("/{id}/messages")
    public ResponseEntity<com.peertutor.dto.MessagesListResponse> getMessages(
            @AuthenticationPrincipal Long userId,
            @PathVariable Long id,
            @RequestParam(required = false, defaultValue = "0") Long afterId) {
        return ResponseEntity.ok(chatService.getMessages(userId, id, afterId));
    }

    /** 20. POST /api/requests/{id}/messages */
    @PostMapping("/{id}/messages")
    public ResponseEntity<com.peertutor.dto.MessageResponse> sendMessage(
            @AuthenticationPrincipal Long userId,
            @PathVariable Long id,
            @Valid @RequestBody com.peertutor.dto.SendMessageRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(chatService.send(userId, id, req.content()));
    }
}
