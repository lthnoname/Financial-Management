package com.example.backend.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record VerifyOtpRequest(
        @NotBlank(message = "Identifier không được để trống")
        @Size(max = 100, message = "Identifier không được vượt quá 100 ký tự")
        String identifier,

        @NotBlank(message = "OTP không được để trống")
        @Pattern(regexp = "\\d{6}", message = "OTP phải gồm đúng 6 chữ số")
        String otp
) {
}
