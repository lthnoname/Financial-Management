package com.example.backend.transaction.controller;

import com.example.backend.transaction.dto.CreateTransactionRequest;
import com.example.backend.transaction.dto.TransactionResponse;
import com.example.backend.transaction.service.TransactionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/transactions")
@Tag(name = "Transaction", description = "Các API quản lý giao dịch thu và chi")
public class TransactionController {

    private final TransactionService transactionService;

    public TransactionController(TransactionService transactionService) {
        this.transactionService = transactionService;
    }

    @PostMapping
    @Operation(summary = "Tạo mới một khoản thu/chi")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Tạo giao dịch thành công"),
            @ApiResponse(responseCode = "400", description = "Dữ liệu đầu vào không hợp lệ hoặc sai loại danh mục"),
            @ApiResponse(responseCode = "401", description = "Chưa xác thực danh tính"),
            @ApiResponse(responseCode = "403", description = "Không có quyền sử dụng danh mục của tài khoản khác"),
            @ApiResponse(responseCode = "404", description = "Không tìm thấy danh mục hoặc người dùng")
    })
    public ResponseEntity<TransactionResponse> createTransaction(
            @Valid @RequestBody CreateTransactionRequest request,
            @RequestHeader(value = "X-User-Id", required = false, defaultValue = "1") Integer currentUserId
    ) {
        TransactionResponse response = transactionService.createTransaction(currentUserId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
}
