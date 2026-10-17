package com.peertutor.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
    name = "chat_messages",
    indexes = {
        @Index(name = "idx_chat_request_id", columnList = "request_id, id")
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "request_id", nullable = false)
    private SessionRequest request;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sender_id", nullable = false)
    private User sender;

    @Column(length = 1000, nullable = false)
    private String content;

    @Column(nullable = false)
    private LocalDateTime sentAt;

    @PrePersist
    void prePersist() {
        if (sentAt == null) {
            sentAt = LocalDateTime.now(com.peertutor.util.ClockHolder.getClock());
        }
    }
}
