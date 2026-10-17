package com.peertutor.service;

import com.peertutor.dto.SubjectResponse;
import com.peertutor.entity.Subject;
import com.peertutor.exception.ApiException;
import com.peertutor.repository.SubjectRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class SubjectService {

    private final SubjectRepository subjectRepository;

    public record SubjectResult(SubjectResponse subject, boolean created) {}

    @Transactional(readOnly = true)
    public List<SubjectResponse> getAllSubjects() {
        return subjectRepository.findAll(Sort.by("id")).stream()
                .map(SubjectResponse::from)
                .toList();
    }

    @Transactional
    public SubjectResult createOrGet(String rawName) {
        String name = rawName != null ? rawName.trim() : "";
        if (name.length() < 2 || name.length() > 60) {
            throw new ApiException(400, "name must be between 2 and 60 characters");
        }

        Optional<Subject> existing = subjectRepository.findByNameIgnoreCase(name);
        if (existing.isPresent()) {
            return new SubjectResult(SubjectResponse.from(existing.get()), false);
        }

        Subject saved = subjectRepository.save(Subject.builder().name(name).build());
        return new SubjectResult(SubjectResponse.from(saved), true);
    }
}
