package com.example.backend.auth;

import jakarta.validation.constraints.NotBlank;

public record LoginRequest(
        @NotBlank(message = "Identifier không được để trống") String identifier,
        @NotBlank(message = "Mật khẩu không được để trống") String password
) {
}
