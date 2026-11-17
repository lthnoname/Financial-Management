package com.example.backend.transaction.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.*;

import java.math.BigDecimal;
import java.time.LocalDate;

public class CreateTransactionRequest {

    @NotBlank(message = "Loại giao dịch không được để trống")
    @Pattern(regexp = "^(INCOME|EXPENSE)$", message = "Loại giao dịch phải là 'INCOME' hoặc 'EXPENSE'")
    @Schema(description = "Loại giao dịch", example = "EXPENSE")
    private String type;

    @NotNull(message = "Số tiền không được để trống")
    @DecimalMin(value = "0.01", message = "Số tiền phải lớn hơn 0")
    @Digits(integer = 13, fraction = 2, message = "Số tiền không hợp lệ")
    @Schema(description = "Số tiền giao dịch (NUMERIC > 0)", example = "150000.00")
    private BigDecimal amount;

    @NotNull(message = "Danh mục không được để trống")
    @Schema(description = "ID của danh mục", example = "1")
    private Integer categoryId;

    @NotNull(message = "Ngày giao dịch không được để trống")
    @PastOrPresent(message = "Ngày giao dịch không được vượt quá ngày hiện tại")
    @Schema(description = "Ngày thực hiện giao dịch", example = "2026-11-17")
    @JsonProperty("date")
    private LocalDate date;

    @Size(max = 500, message = "Ghi chú không được vượt quá 500 ký tự")
    @Schema(description = "Ghi chú thêm", example = "Ăn trưa cùng nhóm")
    private String note;

    public CreateTransactionRequest() {
    }

    public CreateTransactionRequest(String type, BigDecimal amount, Integer categoryId, LocalDate date, String note) {
        this.type = type;
        this.amount = amount;
        this.categoryId = categoryId;
        this.date = date;
        this.note = note;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public Integer getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Integer categoryId) {
        this.categoryId = categoryId;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}
