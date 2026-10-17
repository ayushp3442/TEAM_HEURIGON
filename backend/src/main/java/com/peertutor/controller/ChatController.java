package com.peertutor.controller;

import com.peertutor.dto.ChatListItemResponse;
import com.peertutor.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Chat controller — Architecture.md §6.8 endpoint 18.
 */
@RestController
@RequestMapping("/api/chats")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    /** 18. GET /api/chats */
    @GetMapping
    public ResponseEntity<List<ChatListItemResponse>> getChats(
            @AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(chatService.listChats(userId));
    }
}
