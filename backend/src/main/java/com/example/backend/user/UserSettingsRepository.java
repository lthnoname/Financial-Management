package com.example.backend.user;

import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;

import java.util.Optional;

public interface UserSettingsRepository extends JpaRepository<UserSettings, Integer> {
    Optional<UserSettings> findByUserId(Integer userId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<UserSettings> findForUpdateByUserId(Integer userId);
}
