package com.example.backend.transaction.service;

import com.example.backend.category.Category;
import com.example.backend.category.CategoryRepository;
import com.example.backend.common.exception.ForbiddenException;
import com.example.backend.common.exception.ResourceNotFoundException;
import com.example.backend.transaction.dto.CreateTransactionRequest;
import com.example.backend.transaction.dto.TransactionResponse;
import com.example.backend.transaction.entity.Transaction;
import com.example.backend.transaction.repository.TransactionRepository;
import com.example.backend.user.User;
import com.example.backend.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class TransactionServiceImpl implements TransactionService {

    private final TransactionRepository transactionRepository;
    private final CategoryRepository categoryRepository;
    private final UserRepository userRepository;

    public TransactionServiceImpl(TransactionRepository transactionRepository,CategoryRepository categoryRepository,UserRepository userRepository) {
        this.transactionRepository = transactionRepository;
        this.categoryRepository = categoryRepository;
        this.userRepository = userRepository;
    }

    @Override
    @Transactional
    public TransactionResponse createTransaction(Integer currentUserId, CreateTransactionRequest request) {
        User currentUser = userRepository.findById(currentUserId).orElseThrow(() -> new ResourceNotFoundException("Người dùng không tồn tại"));
        Category category = categoryRepository.findById(request.getCategoryId()).orElseThrow(() -> new ResourceNotFoundException("Danh mục không tồn tại"));
        //Kiem tra quyen so huu
        if (!category.getUser().getId().equals(currentUserId)) {
            throw new ForbiddenException("Bạn không có quyền sử dụng danh mục này");
        }
        //Kiem tra loai danh muc va loai giao dich
        if (!category.getType().equalsIgnoreCase(request.getType())) {
            throw new IllegalArgumentException(
                    String.format("Danh mục '%s' có loại là %s, không khớp với loại giao dịch %s", category.getName(), category.getType(), request.getType())
            );
        }
        Transaction transaction = new Transaction(
                currentUser,
                category,
                request.getAmount(),
                request.getDate(),
                request.getNote()
        );
        Transaction savedTransaction = transactionRepository.save(transaction);
        return new TransactionResponse(
                savedTransaction.getId(),
                currentUser.getId(),
                category.getId(),
                category.getName(),
                category.getType(),
                savedTransaction.getAmount(),
                savedTransaction.getTransactionDate(),
                savedTransaction.getNote(),
                savedTransaction.getCreatedAt()
        );
    }
}
