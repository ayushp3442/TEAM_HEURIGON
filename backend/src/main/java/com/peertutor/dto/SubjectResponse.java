package com.peertutor.dto;

import com.peertutor.entity.Subject;

/** Subject item returned in subject lists and tutor profiles — §6.3, §6.4 */
public record SubjectResponse(
    Long id,
    String name
) {
    public static SubjectResponse from(Subject subject) {
        return new SubjectResponse(subject.getId(), subject.getName());
    }
}
