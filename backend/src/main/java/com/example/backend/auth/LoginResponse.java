package com.example.backend.auth;

public record LoginResponse(
        String accessToken,
        String refreshToken,
        UserAuthResponse user
) {
}
