package com.example.backend.transaction.service;

import com.example.backend.transaction.dto.CreateTransactionRequest;
import com.example.backend.transaction.dto.TransactionResponse;

public interface TransactionService {
    TransactionResponse createTransaction(Integer currentUserId, CreateTransactionRequest request);
}
