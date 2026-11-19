package com.example.backend.user;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_settings")
public class UserSettings {

    @Id
    private Integer id;

    @Column(name = "user_id", nullable = false, unique = true, updatable = false)
    private Integer userId;

    @Column(nullable = false, length = 10)
    private String currency;

    @Column(nullable = false, length = 50)
    private String timezone;

    @Column(name = "opening_balance", nullable = false, precision = 15, scale = 2)
    private BigDecimal openingBalance;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    protected UserSettings() {
    }

    public String getCurrency() {
        return currency;
    }

    public String getTimezone() {
        return timezone;
    }

    public BigDecimal getOpeningBalance() {
        return openingBalance;
    }

    void update(String currency, String timezone, BigDecimal openingBalance) {
        this.currency = currency;
        this.timezone = timezone;
        this.openingBalance = openingBalance;
        this.updatedAt = LocalDateTime.now();
    }
}
