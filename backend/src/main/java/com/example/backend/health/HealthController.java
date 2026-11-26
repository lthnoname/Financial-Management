package com.example.backend.health;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/health")
@Tag(name = "Health", description = "Service availability")
public class HealthController {

    @GetMapping
    @Operation(summary = "Check API availability")
    public HealthResponse getHealth() {
        return new HealthResponse("UP");
    }

    public record HealthResponse(String status) {
    }
}
