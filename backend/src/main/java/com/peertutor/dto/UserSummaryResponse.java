package com.peertutor.dto;

/** Minimal user summary inside request objects — §6.6 */
public record UserSummaryResponse(
    Long id,
    String name
) {}
