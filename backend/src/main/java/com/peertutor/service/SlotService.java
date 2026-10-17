package com.peertutor.service;

import com.peertutor.dto.MySlotResponse;
import com.peertutor.dto.SlotRequest;
import com.peertutor.dto.SlotResponse;
import com.peertutor.entity.AvailabilitySlot;
import com.peertutor.entity.TutorProfile;
import com.peertutor.enums.RequestStatus;
import com.peertutor.exception.ApiException;
import com.peertutor.repository.SessionRequestRepository;
import com.peertutor.repository.SlotRepository;
import com.peertutor.repository.TutorProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SlotService {

    private final SlotRepository slotRepository;
    private final TutorProfileRepository tutorProfileRepository;
    private final SessionRequestRepository sessionRequestRepository;
    private final Clock clock;

    @Value("${app.slot.min-lead-minutes:2}")
    private long minLeadMinutes;

    @Value("${app.slot.min-duration-minutes:5}")
    private long minDurationMinutes;

    @Transactional
    public SlotResponse create(Long userId, SlotRequest req) {
        TutorProfile tutor = tutorProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException(404, "Tutor profile not found"));

        if (req.startTime() == null) {
            throw new ApiException(400, "startTime is required");
        }
        if (req.endTime() == null) {
            throw new ApiException(400, "endTime is required");
        }
        if (req.mode() == null) {
            throw new ApiException(400, "mode is required");
        }
        if (req.locationOrLink() == null || req.locationOrLink().trim().isEmpty()) {
            throw new ApiException(400, "locationOrLink is required");
        }

        LocalDateTime now = LocalDateTime.now(clock);
        LocalDateTime minLeadTime = now.plusMinutes(minLeadMinutes);

        if (req.startTime().isBefore(minLeadTime)) {
            throw new ApiException(400, "Start time must be at least " + minLeadMinutes + " minutes from now");
        }

        if (!req.endTime().isAfter(req.startTime())) {
            throw new ApiException(400, "End time must be after start time");
        }

        long durationMinutes = Duration.between(req.startTime(), req.endTime()).toMinutes();
        if (durationMinutes < minDurationMinutes) {
            throw new ApiException(400, "Duration must be at least " + minDurationMinutes + " minutes");
        }

        AvailabilitySlot slot = AvailabilitySlot.builder()
                .tutor(tutor)
                .startTime(req.startTime())
                .endTime(req.endTime())
                .mode(req.mode())
                .locationOrLink(req.locationOrLink().trim())
                .booked(false)
                .build();

        slot = slotRepository.save(slot);
        return SlotResponse.from(slot);
    }

    @Transactional(readOnly = true)
    public List<MySlotResponse> getMySlots(Long userId) {
        TutorProfile tutor = tutorProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ApiException(404, "Tutor profile not found"));

        LocalDateTime now = LocalDateTime.now(clock);
        List<AvailabilitySlot> slots = slotRepository.findActiveSlotsForTutor(tutor.getId(), now);
        if (slots.isEmpty()) {
            return List.of();
        }

        List<Long> slotIds = slots.stream().map(AvailabilitySlot::getId).toList();
        java.util.Map<Long, Long> counts = sessionRequestRepository.countBySlotIdsAndStatus(slotIds, RequestStatus.PENDING)
                .stream()
                .collect(java.util.stream.Collectors.toMap(row -> (Long) row[0], row -> (Long) row[1]));

        return slots.stream()
                .map(slot -> MySlotResponse.from(slot, counts.getOrDefault(slot.getId(), 0L)))
                .toList();
    }

    @Transactional
    public void delete(Long userId, Long slotId) {
        AvailabilitySlot slot = slotRepository.findById(slotId)
                .orElseThrow(() -> new ApiException(404, "Slot not found"));

        if (!slot.getTutor().getUser().getId().equals(userId)) {
            throw new ApiException(403, "You do not own this slot");
        }

        if (slot.isBooked()) {
            throw new ApiException(409, "Cannot delete a booked slot");
        }

        slotRepository.delete(slot);
    }

    @Transactional(readOnly = true)
    public List<SlotResponse> getOpenFutureSlots(Long tutorProfileId) {
        if (!tutorProfileRepository.existsById(tutorProfileId)) {
            throw new ApiException(404, "Tutor profile not found");
        }

        LocalDateTime now = LocalDateTime.now(clock);
        return slotRepository.findOpenFutureSlotsForTutor(tutorProfileId, now).stream()
                .map(SlotResponse::from)
                .toList();
    }
}
