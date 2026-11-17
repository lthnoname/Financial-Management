package com.example.backend.transaction;

import com.example.backend.category.Category;
import com.example.backend.category.CategoryRepository;
import com.example.backend.common.exception.ForbiddenException;
import com.example.backend.common.exception.ResourceNotFoundException;
import com.example.backend.transaction.dto.CreateTransactionRequest;
import com.example.backend.transaction.dto.TransactionResponse;
import com.example.backend.transaction.entity.Transaction;
import com.example.backend.transaction.repository.TransactionRepository;
import com.example.backend.transaction.service.TransactionServiceImpl;
import com.example.backend.user.User;
import com.example.backend.user.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TransactionServiceTest {
    @Mock
    private TransactionRepository transactionRepository;
    @Mock
    private CategoryRepository categoryRepository;
    @Mock
    private UserRepository userRepository;
    @InjectMocks
    private TransactionServiceImpl transactionService;

    private User mockUser;
    private Category mockExpenseCategory;

    @BeforeEach
    void setUp() {
        mockUser = new User();
        mockUser.setId(1);
        mockUser.setIdentifier("test@gmail.com");

        mockExpenseCategory = new Category();
        mockExpenseCategory.setId(10);
        mockExpenseCategory.setName("Ăn uống");
        mockExpenseCategory.setType("EXPENSE");
        mockExpenseCategory.setUser(mockUser);
    }

    @Test
    @DisplayName("FR-06: Thêm khoản chi tiêu thành công")
    void createTransaction_Success_Expense() {
        CreateTransactionRequest request = new CreateTransactionRequest(
                "EXPENSE",
                new BigDecimal("150000.00"),
                10,
                LocalDate.now(),
                "Ăn trưa bún bò"
        );

        Transaction savedTx = new Transaction(
                mockUser,
                mockExpenseCategory,
                request.getAmount(),
                request.getDate(),
                request.getNote()
        );
        savedTx.setId(100);

        when(userRepository.findById(1)).thenReturn(Optional.of(mockUser));
        when(categoryRepository.findById(10)).thenReturn(Optional.of(mockExpenseCategory));
        when(transactionRepository.save(any(Transaction.class))).thenReturn(savedTx);

        TransactionResponse response = transactionService.createTransaction(1, request);

        assertNotNull(response);
        assertEquals(100, response.getId());
        assertEquals(new BigDecimal("150000.00"), response.getAmount());
        assertEquals("EXPENSE", response.getType());
        assertEquals("Ăn uống", response.getCategoryName());
        verify(transactionRepository, times(1)).save(any(Transaction.class));
    }

    @Test
    @DisplayName("NFR-02: Chặn truy cập chéo - Category thuộc về người dùng khác (403 Forbidden)")
    void createTransaction_Forbidden_CategoryBelongsToAnotherUser() {
        User anotherUser = new User();
        anotherUser.setId(2);
        mockExpenseCategory.setUser(anotherUser);

        CreateTransactionRequest request = new CreateTransactionRequest(
                "EXPENSE",
                new BigDecimal("50000.00"),
                10,
                LocalDate.now(),
                "Ăn tối"
        );

        when(userRepository.findById(1)).thenReturn(Optional.of(mockUser));
        when(categoryRepository.findById(10)).thenReturn(Optional.of(mockExpenseCategory));

        ForbiddenException exception = assertThrows(ForbiddenException.class, () -> {
            transactionService.createTransaction(1, request);
        });

        assertEquals("Bạn không có quyền sử dụng danh mục này", exception.getMessage());
        verify(transactionRepository, never()).save(any(Transaction.class));
    }

    @Test
    @DisplayName("US-04: Báo lỗi khi loại danh mục không khớp với loại giao dịch (400 Bad Request)")
    void createTransaction_MismatchCategoryType() {
        CreateTransactionRequest request = new CreateTransactionRequest(
                "INCOME",
                new BigDecimal("2000000.00"),
                10,
                LocalDate.now(),
                "Lương"
        );

        when(userRepository.findById(1)).thenReturn(Optional.of(mockUser));
        when(categoryRepository.findById(10)).thenReturn(Optional.of(mockExpenseCategory));

        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            transactionService.createTransaction(1, request);
        });

        assertTrue(exception.getMessage().contains("không khớp"));
        verify(transactionRepository, never()).save(any(Transaction.class));
    }

    @Test
    @DisplayName("Báo lỗi khi không tìm thấy danh mục (404 Not Found)")
    void createTransaction_CategoryNotFound() {
        CreateTransactionRequest request = new CreateTransactionRequest(
                "EXPENSE",
                new BigDecimal("50000.00"),
                999,
                LocalDate.now(),
                "Ăn tối"
        );

        when(userRepository.findById(1)).thenReturn(Optional.of(mockUser));
        when(categoryRepository.findById(999)).thenReturn(Optional.empty());

        assertThrows(ResourceNotFoundException.class, () -> {
            transactionService.createTransaction(1, request);
        });

        verify(transactionRepository, never()).save(any(Transaction.class));
    }
}
