package com.peertutor.exception;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Clock;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Global exception handler — §4.8.
 * Every error returns:
 *   {"status":N,"error":"...","message":"...","timestamp":"2026-10-17T10:15:30"}
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");

    private final Clock clock;

    public GlobalExceptionHandler(Clock clock) {
        this.clock = clock;
    }

    // ---- helpers --------------------------------------------------------

    private Map<String, Object> body(int status, String error, String message) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("status", status);
        m.put("error", error);
        m.put("message", message);
        m.put("timestamp", LocalDateTime.now(clock).format(FMT));
        return m;
    }

    // ---- handlers -------------------------------------------------------

    /** ApiException → its own status code */
    @ExceptionHandler(ApiException.class)
    public ResponseEntity<Map<String, Object>> handleApi(ApiException ex) {
        HttpStatus hs = HttpStatus.resolve(ex.getStatus());
        String error = hs != null ? hs.getReasonPhrase() : "Error";
        return ResponseEntity.status(ex.getStatus()).body(body(ex.getStatus(), error, ex.getMessage()));
    }

    /** Bean Validation (@Valid) → 400 with first field error */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidation(MethodArgumentNotValidException ex) {
        String msg = ex.getBindingResult().getFieldErrors().stream()
                .findFirst()
                .map(fe -> fe.getDefaultMessage() != null ? fe.getDefaultMessage() : fe.getField() + " is invalid")
                .orElse("Validation error");
        return ResponseEntity.badRequest().body(body(400, "Bad Request", msg));
    }

    /** Malformed / missing JSON body → 400 */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<Map<String, Object>> handleUnreadable(HttpMessageNotReadableException ex) {
        return ResponseEntity.badRequest().body(body(400, "Bad Request", "Malformed or missing request body"));
    }

    /** @PreAuthorize violation → 403 */
    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<Map<String, Object>> handleAccess(AccessDeniedException ex) {
        return ResponseEntity.status(403).body(body(403, "Forbidden", "Access denied"));
    }

    /** Optimistic lock failure (@Version) → 409 */
    @ExceptionHandler({
        org.springframework.orm.ObjectOptimisticLockingFailureException.class,
        jakarta.persistence.OptimisticLockException.class
    })
    public ResponseEntity<Map<String, Object>> handleOptimisticLock(Exception ex) {
        return ResponseEntity.status(409).body(body(409, "Conflict", "The resource was modified concurrently; please retry"));
    }

    /** Unique constraint / data integrity violation → 409 */
    @ExceptionHandler(org.springframework.dao.DataIntegrityViolationException.class)
    public ResponseEntity<Map<String, Object>> handleDataIntegrity(org.springframework.dao.DataIntegrityViolationException ex) {
        return ResponseEntity.status(409).body(body(409, "Conflict", "A conflict occurred with existing data"));
    }

    /** 404 Not Found (unmapped URL) */
    @ExceptionHandler({
        org.springframework.web.servlet.resource.NoResourceFoundException.class,
        org.springframework.web.servlet.NoHandlerFoundException.class
    })
    public ResponseEntity<Map<String, Object>> handleNotFound(Exception ex) {
        return ResponseEntity.status(404).body(body(404, "Not Found", "Endpoint not found"));
    }

    /** 405 Method Not Allowed (wrong HTTP method) */
    @ExceptionHandler(org.springframework.web.HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<Map<String, Object>> handleMethodNotSupported(org.springframework.web.HttpRequestMethodNotSupportedException ex) {
        return ResponseEntity.status(405).body(body(405, "Method Not Allowed", "HTTP method " + ex.getMethod() + " is not supported for this endpoint"));
    }

    /** 400 Bad Request on query param / path variable type mismatch */
    @ExceptionHandler({
        org.springframework.web.method.annotation.MethodArgumentTypeMismatchException.class,
        org.springframework.web.bind.MissingServletRequestParameterException.class,
        org.springframework.beans.TypeMismatchException.class
    })
    public ResponseEntity<Map<String, Object>> handleTypeMismatch(Exception ex) {
        return ResponseEntity.badRequest().body(body(400, "Bad Request", "Invalid parameter or format"));
    }

    /** Catch-all → 500, no stack trace in response */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleAll(Exception ex, HttpServletRequest req) {
        ex.printStackTrace();
        return ResponseEntity.status(500).body(body(500, "Internal Server Error", "An unexpected error occurred"));
    }
}

