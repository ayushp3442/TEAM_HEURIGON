package com.peertutor.dto;

import com.peertutor.enums.ChatState;
import java.time.LocalDateTime;

/** Chat state info embedded in requests and chat responses — Architecture.md §6.8 */
public record ChatInfo(
    ChatState state,
    LocalDateTime opensAt,
    LocalDateTime closesAt
) {}
