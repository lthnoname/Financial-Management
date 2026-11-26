package com.example.backend.auth;

public record UserAuthResponse(
        Integer id,
        String identifier,
        String fullName
) {
}
