package com.example.backend.transaction;

import jdk.jfr.DataAmount;
import lombok.*;
import tools.jackson.databind.annotation.JsonPOJOBuilder;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TransactionResponse {
    private Long id;
    private Long userId;
    private Long categoryId;
    private String categoryName;
    private String type;
    private BigDecimal amount;
    private LocalDate transactionDate;
    private String note;
    private LocalDateTime createdAt;
}