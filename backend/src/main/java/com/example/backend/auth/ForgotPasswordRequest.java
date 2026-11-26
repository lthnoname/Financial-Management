package com.example.backend.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ForgotPasswordRequest(
        @NotBlank(message = "Identifier không được để trống")
        @Size(max = 100, message = "Identifier không được vượt quá 100 ký tự")
        String identifier
) {
}
