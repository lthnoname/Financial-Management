package com.example.backend.user;

import com.example.backend.common.AuthException;
import com.example.backend.user.WalletSettingsController.UpdateWallet;
import com.example.backend.user.WalletSettingsController.WalletProfile;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.ZoneId;
import java.util.Currency;
import java.util.Locale;

@Service
public class WalletSettingsService {

    private static final BigDecimal MAX_OPENING_BALANCE = new BigDecimal("9999999999999.99");
    private final UserSettingsRepository repository;

    public WalletSettingsService(UserSettingsRepository repository) {
        this.repository = repository;
    }

    @Transactional(readOnly = true)
    public WalletProfile get(User user) {
        return WalletProfile.from(user, repository.findByUserId(user.getId()).orElseThrow());
    }

    @Transactional
    public WalletProfile update(User user, UpdateWallet request) {
        if (request.currency() == null && request.timezone() == null && request.openingBalance() == null) {
            throw invalid("Cần cung cấp ít nhất một thiết lập ví.");
        }

        UserSettings settings = repository.findForUpdateByUserId(user.getId()).orElseThrow();
        String currency = request.currency() == null ? settings.getCurrency() : currencyCode(request.currency());
        String timezone = request.timezone() == null ? settings.getTimezone() : timezoneId(request.timezone());
        BigDecimal balance = request.openingBalance() == null
                ? settings.getOpeningBalance() : openingBalance(request.openingBalance());

        settings.update(currency, timezone, balance);
        return WalletProfile.from(user, settings);
    }

    private String currencyCode(String value) {
        try {
            return Currency.getInstance(value.strip().toUpperCase(Locale.ROOT)).getCurrencyCode();
        } catch (IllegalArgumentException ex) {
            throw invalid("Tiền tệ phải là mã ISO 4217 hợp lệ, ví dụ VND.");
        }
    }

    private String timezoneId(String value) {
        String zone = value.strip();
        if (zone.length() > 50 || !ZoneId.getAvailableZoneIds().contains(zone)) {
            throw invalid("Múi giờ phải là mã IANA hợp lệ, ví dụ Asia/Saigon.");
        }
        return zone;
    }

    private BigDecimal openingBalance(BigDecimal amount) {
        if (amount.signum() < 0 || amount.compareTo(MAX_OPENING_BALANCE) > 0
                || amount.stripTrailingZeros().scale() > 2) {
            throw invalid("Số dư đầu kỳ phải từ 0 đến 9999999999999.99 và có tối đa hai chữ số thập phân.");
        }
        return amount.setScale(2);
    }

    private AuthException invalid(String message) {
        return new AuthException(HttpStatus.UNPROCESSABLE_ENTITY, message);
    }
}
