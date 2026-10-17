package com.peertutor.exception;

import lombok.Getter;

/**
 * Application exception that carries an HTTP status code and message.
 * Thrown by services; caught by GlobalExceptionHandler.
 */
@Getter
public class ApiException extends RuntimeException {

    private final int status;

    public ApiException(int status, String message) {
        super(message);
        this.status = status;
    }
}
