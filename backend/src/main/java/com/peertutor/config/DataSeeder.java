package com.peertutor.config;

import com.peertutor.entity.Subject;
import com.peertutor.repository.SubjectRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * Seeds the subjects catalog on first startup only.
 * §4.9: inserts these 10 subjects IFF the subjects table is empty.
 * No users, tutors, slots, requests, or messages are seeded.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class DataSeeder implements CommandLineRunner {

    private static final List<String> SUBJECT_NAMES = List.of(
        "Mathematics",
        "Physics",
        "Chemistry",
        "Data Structures",
        "DBMS",
        "Operating Systems",
        "Computer Networks",
        "English",
        "Economics",
        "Machine Learning"
    );

    private final SubjectRepository subjectRepository;

    @Override
    public void run(String... args) {
        if (subjectRepository.count() == 0) {
            List<Subject> subjects = SUBJECT_NAMES.stream()
                .map(name -> Subject.builder().name(name).build())
                .toList();
            subjectRepository.saveAll(subjects);
            log.info("DataSeeder: inserted {} subjects into catalog.", subjects.size());
        } else {
            log.info("DataSeeder: subjects table already populated, skipping seed.");
        }
    }
}
