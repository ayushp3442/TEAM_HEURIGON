package com.peertutor.repository;

import com.peertutor.entity.ChatMessage;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {

    @EntityGraph(attributePaths = {"sender"})
    List<ChatMessage> findByRequestIdAndIdGreaterThanOrderByIdAsc(Long requestId, Long id);

    @Query("SELECT m FROM ChatMessage m JOIN FETCH m.sender WHERE m.request.id = :requestId ORDER BY m.id DESC LIMIT 1")
    Optional<ChatMessage> findLatestByRequestId(@Param("requestId") Long requestId);

    @Query("""
        SELECT m FROM ChatMessage m JOIN FETCH m.sender
        WHERE m.id IN (
            SELECT MAX(m2.id) FROM ChatMessage m2 WHERE m2.request.id IN :requestIds GROUP BY m2.request.id
        )
    """)
    List<ChatMessage> findLatestByRequestIds(@Param("requestIds") Collection<Long> requestIds);
}
