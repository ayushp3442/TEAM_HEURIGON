package com.peertutor.service;

import com.peertutor.dto.NextSlotResponse;
import com.peertutor.dto.SubjectResponse;
import com.peertutor.dto.TutorCardResponse;
import com.peertutor.dto.TutorProfileRequest;
import com.peertutor.dto.TutorProfileResponse;
import com.peertutor.entity.AvailabilitySlot;
import com.peertutor.entity.Subject;
import com.peertutor.entity.TutorProfile;
import com.peertutor.entity.User;
import com.peertutor.enums.Mode;
import com.peertutor.exception.ApiException;
import com.peertutor.repository.SubjectRepository;
import com.peertutor.repository.TutorProfileRepository;
import com.peertutor.repository.UserRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.criteria.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.*;

@Service
@RequiredArgsConstructor
public class TutorService {

    private final TutorProfileRepository tutorProfileRepository;
    private final UserRepository userRepository;
    private final SubjectRepository subjectRepository;
    private final Clock clock;

    @PersistenceContext
    private EntityManager em;

    @Transactional(readOnly = true)
    public TutorProfileResponse getMyProfile(Long userId) {
        TutorProfile profile = tutorProfileRepository.findByUserIdWithDetails(userId)
                .orElseThrow(() -> new ApiException(404, "Tutor profile not found"));
        return TutorProfileResponse.from(profile);
    }

    @Transactional
    public TutorProfileResponse updateProfile(Long userId, TutorProfileRequest req) {
        if (req.subjectIds() == null || req.subjectIds().isEmpty()) {
            throw new ApiException(400, "at least one subject is required");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(404, "User not found"));

        List<Subject> subjects = subjectRepository.findAllById(req.subjectIds());
        if (subjects.isEmpty()) {
            throw new ApiException(400, "at least one valid subject is required");
        }
        if (subjects.size() != req.subjectIds().size()) {
            throw new ApiException(400, "one or more subject IDs do not exist");
        }

        Optional<TutorProfile> existingOpt = tutorProfileRepository.findByUserId(userId);
        TutorProfile profile;
        if (existingOpt.isPresent()) {
            profile = existingOpt.get();
            profile.setBio(req.bio());
            profile.setDepartment(req.department());
            profile.setYearOfStudy(req.yearOfStudy());
            profile.setSubjects(new HashSet<>(subjects));
        } else {
            profile = TutorProfile.builder()
                    .user(user)
                    .bio(req.bio())
                    .department(req.department())
                    .yearOfStudy(req.yearOfStudy())
                    .subjects(new HashSet<>(subjects))
                    .build();
        }

        profile = tutorProfileRepository.save(profile);
        return TutorProfileResponse.from(profile);
    }

    @Transactional(readOnly = true)
    public TutorProfileResponse getProfileById(Long id) {
        TutorProfile profile = tutorProfileRepository.findByIdWithDetails(id)
                .orElseThrow(() -> new ApiException(404, "Tutor profile not found"));
        return TutorProfileResponse.from(profile);
    }

    @Transactional(readOnly = true)
    public List<TutorCardResponse> searchTutors(Long currentUserId, Long subjectId, String modeStr, String dateStr) {
        Mode mode = null;
        if (modeStr != null && !modeStr.trim().isEmpty()) {
            try {
                mode = Mode.valueOf(modeStr.trim().toUpperCase());
            } catch (IllegalArgumentException ex) {
                throw new ApiException(400, "mode must be ONLINE or ON_CAMPUS");
            }
        }

        LocalDateTime from = null;
        LocalDateTime to = null;
        if (dateStr != null && !dateStr.trim().isEmpty()) {
            try {
                LocalDate localDate = LocalDate.parse(dateStr.trim());
                from = localDate.atStartOfDay();
                to = localDate.plusDays(1).atStartOfDay();
            } catch (DateTimeParseException ex) {
                throw new ApiException(400, "date must be in YYYY-MM-DD format");
            }
        }

        LocalDateTime now = LocalDateTime.now(clock);

        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<AvailabilitySlot> cq = cb.createQuery(AvailabilitySlot.class);
        Root<AvailabilitySlot> root = cq.from(AvailabilitySlot.class);

        // Fetch join tutor, user, and subjects in a single query
        Fetch<AvailabilitySlot, TutorProfile> tutorFetch = root.fetch("tutor", JoinType.INNER);
        tutorFetch.fetch("user", JoinType.INNER);
        tutorFetch.fetch("subjects", JoinType.LEFT);

        List<Predicate> preds = new ArrayList<>();
        preds.add(cb.isFalse(root.get("booked")));
        preds.add(cb.greaterThan(root.get("startTime"), now));

        if (mode != null) {
            preds.add(cb.equal(root.get("mode"), mode));
        }
        if (from != null) {
            preds.add(cb.greaterThanOrEqualTo(root.get("startTime"), from));
        }
        if (to != null) {
            preds.add(cb.lessThan(root.get("startTime"), to));
        }
        if (currentUserId != null) {
            preds.add(cb.notEqual(root.get("tutor").get("user").get("id"), currentUserId));
        }
        if (subjectId != null) {
            Subquery<Integer> sub = cq.subquery(Integer.class);
            Root<TutorProfile> tpRoot = sub.from(TutorProfile.class);
            Join<TutorProfile, Subject> subjJoin = tpRoot.join("subjects");
            sub.select(cb.literal(1))
               .where(cb.equal(tpRoot, root.get("tutor")), cb.equal(subjJoin.get("id"), subjectId));
            preds.add(cb.exists(sub));
        }

        cq.where(preds.toArray(new Predicate[0]));
        cq.orderBy(cb.asc(root.get("startTime")));

        List<AvailabilitySlot> slots = em.createQuery(cq).getResultList();
        if (slots.isEmpty()) {
            return List.of();
        }

        Map<Long, Set<Long>> tutorSlotIds = new LinkedHashMap<>();
        Map<Long, AvailabilitySlot> tutorFirstSlot = new LinkedHashMap<>();
        Map<Long, TutorProfile> tutorProfiles = new LinkedHashMap<>();

        for (AvailabilitySlot slot : slots) {
            Long tutorId = slot.getTutor().getId();
            tutorProfiles.putIfAbsent(tutorId, slot.getTutor());
            tutorFirstSlot.putIfAbsent(tutorId, slot);
            tutorSlotIds.computeIfAbsent(tutorId, k -> new LinkedHashSet<>()).add(slot.getId());
        }

        List<TutorCardResponse> results = new ArrayList<>();
        for (Long tutorId : tutorProfiles.keySet()) {
            TutorProfile tutor = tutorProfiles.get(tutorId);
            AvailabilitySlot earliestSlot = tutorFirstSlot.get(tutorId);
            long openSlotCount = tutorSlotIds.get(tutorId).size();

            NextSlotResponse nextSlot = new NextSlotResponse(earliestSlot.getStartTime(), earliestSlot.getMode());

            List<SubjectResponse> subjects = tutor.getSubjects() == null
                    ? List.of()
                    : tutor.getSubjects().stream()
                        .map(SubjectResponse::from)
                        .sorted(Comparator.comparing(SubjectResponse::id))
                        .toList();

            results.add(new TutorCardResponse(
                    tutor.getId(),
                    tutor.getUser() != null ? tutor.getUser().getName() : null,
                    tutor.getBio(),
                    tutor.getDepartment(),
                    tutor.getYearOfStudy(),
                    subjects,
                    openSlotCount,
                    nextSlot
            ));
        }

        results.sort(Comparator.comparing(r -> r.nextSlot().startTime()));
        return results;
    }
}
