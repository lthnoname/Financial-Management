package com.example.backend.transaction;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.*;
import jdk.jfr.DataAmount;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateTransactionRequest {
    @NotBlank(message = "Loại giao dịch không được để trống")
    @Pattern(regexp = "^(INCOME|EXPENSE)$", message = "Loại giao dịch phải là INCOME hoặc EXPENSE")
    @Schema(description = "Loại giao dịch (INCOME hoặc EXPENSE)", example ="EXPENSE")
    private String type;

    @NotNull
    @DecimalMin(value = "0.01", message = "Số tiền phải lớn hơn 0")
    @Digits(integer = 13, fraction = 2, message = "Số tiền không hợp lệ")
    @Schema(description = "Số tiền của giao dịch (NUMERIC>0)", example = "100.00")
    private BigDecimal amount;

    @NotNull(message = "Danh mục không được để trống")
    @Schema(description = "ID của danh mục giao dịch", example = "1")
    private Long categoryId;

    @NotNull(message="Ngày giao dịch không được để trống")
    @PastOrPresent(message = "Ngày giao dịch không được là ngày trong tương lai")
    @Schema(description = "Ngày giao dịch (không được là ngày trong tương lai)", example = "2023-08-15")
    private LocalDate transactionDate;

    @Size(max=500,message = "Ghi chú không được vượt quá 500 ký tự")
    @Schema(description = "Ghi chú cho giao dịch (tối đa 500 ký)", example = "Mua sắm tại siêu thị")
    private String note;
}