package com.example.backend.category.transaction;

import com.example.backend.category.entity.Category;
import com.example.backend.user.User;
import jakarta.persistence.*;
import lombok.*;
import tools.jackson.databind.annotation.JsonPOJOBuilder;

@Entity
@Table (name="transactions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne (fetch = FetchType.LAZY)
    @JoinColumn(name="user_id", nullable = false)
    private User user;

    @ManyToOne (fetch = FetchType.LAZY)
    @JoinColumn(name="category_id", nullable = false)
    private Category category;

    @Column(nullable = false,length = 20)
    private String amount;

    @Column(name="transaction_date",nullable = false)
    private LocalDate transactionDate;

    @Column(columnDefinition = "TEXT")
    private String note;

    @Column(name="created_at",insertable = false,updatable = false)
    private LocalDateTime createdAt;
}