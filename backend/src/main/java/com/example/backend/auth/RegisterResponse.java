package com.example.backend.auth;

public class RegisterResponse {
    private Integer userId;
    private Boolean verificationRequired;
    private String message;

    public RegisterResponse() {
    }

    public RegisterResponse(Integer userId, Boolean verificationRequired, String message) {
        this.userId = userId;
        this.verificationRequired = verificationRequired;
        this.message = message;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Boolean getVerificationRequired() {
        return verificationRequired;
    }

    public void setVerificationRequired(Boolean verificationRequired) {
        this.verificationRequired = verificationRequired;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}