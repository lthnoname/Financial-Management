package com.example.backend.user;

import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.security.Principal;

@RestController
@RequestMapping("/api/v1/me")
@Tag(name = "Wallet settings")
public class WalletSettingsController {

    private final WalletSettingsService settings;
    private final CurrentUser currentUser;

    public WalletSettingsController(WalletSettingsService settings, CurrentUser currentUser) {
        this.settings = settings;
        this.currentUser = currentUser;
    }

    @GetMapping
    public WalletProfile get(Principal principal) {
        return settings.get(currentUser.require(principal));
    }

    @PatchMapping
    public WalletProfile update(Principal principal, @RequestBody UpdateWallet request) {
        return settings.update(currentUser.require(principal), request);
    }

    public record UpdateWallet(String currency, String timezone, BigDecimal openingBalance) {}

    public record WalletProfile(Integer id, String identifier, String fullName, String currency,
                                String timezone, BigDecimal openingBalance) {
        static WalletProfile from(User user, UserSettings settings) {
            return new WalletProfile(user.getId(), user.getIdentifier(), user.getFullName(),
                    settings.getCurrency(), settings.getTimezone(), settings.getOpeningBalance());
        }
    }
}
