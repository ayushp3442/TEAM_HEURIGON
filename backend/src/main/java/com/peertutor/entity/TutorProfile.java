package com.peertutor.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "tutor_profiles")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class TutorProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // §5: user_id BIGINT NOT NULL UNIQUE REFERENCES users(id)
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    // §5: bio VARCHAR(500)
    @Column(length = 500)
    private String bio;

    // §5: department VARCHAR(100)
    @Column(length = 100)
    private String department;

    // §5: year_of_study INT
    private Integer yearOfStudy;

    // §5: tutor_subjects join table — (tutor_profile_id, subject_id) PK
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "tutor_subjects",
        joinColumns = @JoinColumn(name = "tutor_profile_id"),
        inverseJoinColumns = @JoinColumn(name = "subject_id")
    )
    @Builder.Default
    private Set<Subject> subjects = new HashSet<>();
}
