package com.example.backend.user;

import com.example.backend.common.AuthException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import java.security.Principal;

@Component
public class CurrentUser {

    private final UserRepository users;

    public CurrentUser(UserRepository users) {
        this.users = users;
    }

    public User require(Principal principal) {
        if (principal == null) {
            throw unauthenticated();
        }
        return users.findByIdentifier(principal.getName()).orElseThrow(this::unauthenticated);
    }

    private AuthException unauthenticated() {
        return new AuthException(HttpStatus.UNAUTHORIZED, "Bạn cần đăng nhập.");
    }
}
