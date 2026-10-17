package com.peertutor.service;

import com.peertutor.dto.CreateSessionRequest;
import com.peertutor.dto.RequestResponse;
import com.peertutor.entity.AvailabilitySlot;
import com.peertutor.entity.SessionRequest;
import com.peertutor.entity.Subject;
import com.peertutor.entity.TutorProfile;
import com.peertutor.entity.User;
import com.peertutor.enums.RequestStatus;
import com.peertutor.exception.ApiException;
import com.peertutor.repository.SessionRequestRepository;
import com.peertutor.repository.SlotRepository;
import com.peertutor.repository.SubjectRepository;
import com.peertutor.repository.TutorProfileRepository;
import com.peertutor.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Business logic for Session Requests — Architecture.md §4.6 & §6.6.
 */
@Service
@RequiredArgsConstructor
public class RequestService {

    private final SessionRequestRepository requestRepo;
    private final SlotRepository slotRepo;
    private final SubjectRepository subjectRepo;
    private final UserRepository userRepo;
    private final TutorProfileRepository tutorProfileRepo;
    private final ChatService chatService;
    private final Clock clock;

    /**
     * Endpoint 13: POST /api/requests (STUDENT)
     */
    @Transactional
    public RequestResponse create(Long studentUserId, CreateSessionRequest req) {
        AvailabilitySlot slot = slotRepo.findDetailedById(req.slotId())
                .orElseThrow(() -> new ApiException(404, "Slot not found"));

        if (slot.isBooked()) {
            throw new ApiException(409, "Slot already booked");
        }

        LocalDateTime now = LocalDateTime.now(clock);
        if (!slot.getStartTime().isAfter(now)) {
            throw new ApiException(400, "Slot is in the past");
        }

        if (slot.getTutor().getUser().getId().equals(studentUserId)) {
            throw new ApiException(403, "Cannot request your own slot");
        }

        Subject subject = subjectRepo.findById(req.subjectId())
                .orElseThrow(() -> new ApiException(400, "Subject not found"));

        boolean teaches = slot.getTutor().getSubjects().stream()
                .anyMatch(s -> s.getId().equals(subject.getId()));
        if (!teaches) {
            throw new ApiException(400, "Subject not taught by the tutor");
        }

        if (requestRepo.existsByStudentIdAndSlotId(studentUserId, slot.getId())) {
            throw new ApiException(409, "Duplicate request for this slot");
        }

        if (req.message() != null && req.message().length() > 300) {
            throw new ApiException(400, "Message must not exceed 300 characters");
        }

        User student = userRepo.findById(studentUserId)
                .orElseThrow(() -> new ApiException(404, "User not found"));

        SessionRequest request = SessionRequest.builder()
                .student(student)
                .tutor(slot.getTutor())
                .slot(slot)
                .subject(subject)
                .message(req.message())
                .status(RequestStatus.PENDING)
                .createdAt(now)
                .build();

        SessionRequest saved = requestRepo.save(request);
        return RequestResponse.from(saved, chatService.chatInfo(saved));
    }

    /**
     * Endpoint 14: GET /api/requests/outgoing (STUDENT; optional ?status=; newest first)
     */
    @Transactional(readOnly = true)
    public List<RequestResponse> listOutgoing(Long studentUserId, RequestStatus status) {
        List<SessionRequest> list = (status != null)
                ? requestRepo.findByStudentIdAndStatusOrderByCreatedAtDesc(studentUserId, status)
                : requestRepo.findByStudentIdOrderByCreatedAtDesc(studentUserId);

        return list.stream().map(r -> RequestResponse.from(r, chatService.chatInfo(r))).toList();
    }

    /**
     * Endpoint 15: PATCH /api/requests/{id}/cancel (STUDENT who owns it; only PENDING)
     */
    @Transactional
    public RequestResponse cancel(Long studentUserId, Long requestId) {
        SessionRequest r = requestRepo.findDetailedById(requestId)
                .orElseThrow(() -> new ApiException(404, "Request not found"));

        if (!r.getStudent().getId().equals(studentUserId)) {
            throw new ApiException(403, "Not your request");
        }

        if (r.getStatus() != RequestStatus.PENDING) {
            throw new ApiException(409, "Only pending requests can be cancelled");
        }

        r.setStatus(RequestStatus.CANCELLED);
        SessionRequest saved = requestRepo.save(r);
        return RequestResponse.from(saved, chatService.chatInfo(saved));
    }

    /**
     * Endpoint 16: GET /api/requests/incoming (TUTOR; optional ?status=; newest first)
     */
    @Transactional(readOnly = true)
    public List<RequestResponse> listIncoming(Long tutorUserId, RequestStatus status) {
        TutorProfile tutor = tutorProfileRepo.findByUserId(tutorUserId)
                .orElseThrow(() -> new ApiException(404, "Tutor profile not found"));

        List<SessionRequest> list = (status != null)
                ? requestRepo.findByTutorIdAndStatusOrderByCreatedAtDesc(tutor.getId(), status)
                : requestRepo.findByTutorIdOrderByCreatedAtDesc(tutor.getId());

        return list.stream().map(r -> RequestResponse.from(r, chatService.chatInfo(r))).toList();
    }

    /**
     * Endpoint 17: PATCH /api/requests/{id}/status (TUTOR who owns it; body {"status":"ACCEPTED"|"DECLINED"})
     */
    @Transactional
    public RequestResponse updateStatus(Long tutorUserId, Long requestId, RequestStatus newStatus) {
        SessionRequest r = requestRepo.findDetailedById(requestId)
                .orElseThrow(() -> new ApiException(404, "Request not found"));

        if (!r.getTutor().getUser().getId().equals(tutorUserId)) {
            throw new ApiException(403, "Not your request");
        }

        if (r.getStatus() != RequestStatus.PENDING) {
            throw new ApiException(409, "Request already handled");
        }

        if (newStatus == RequestStatus.ACCEPTED) {
            AvailabilitySlot slot = r.getSlot();
            if (slot.isBooked()) {
                throw new ApiException(409, "Slot already booked");
            }
            if (!slot.getStartTime().isAfter(LocalDateTime.now(clock))) {
                throw new ApiException(409, "Slot has already started");
            }
            slot.setBooked(true);
            slotRepo.save(slot);
            r.setStatus(RequestStatus.ACCEPTED);

            // Auto-decline other pending requests for this slot (§4.6)
            List<SessionRequest> otherPending = requestRepo.findBySlotIdAndStatus(slot.getId(), RequestStatus.PENDING);
            for (SessionRequest o : otherPending) {
                if (!o.getId().equals(r.getId())) {
                    o.setStatus(RequestStatus.DECLINED);
                }
            }
            requestRepo.saveAll(otherPending);
        } else if (newStatus == RequestStatus.DECLINED) {
            r.setStatus(RequestStatus.DECLINED);
        } else {
            throw new ApiException(400, "Status must be ACCEPTED or DECLINED");
        }

        SessionRequest saved = requestRepo.save(r);
        return RequestResponse.from(saved, chatService.chatInfo(saved));
    }
}
