package com.example.backend;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {"spring.flyway.enabled=true", "spring.jpa.hibernate.ddl-auto=validate"})
@AutoConfigureMockMvc
@ActiveProfiles("test")
class Sprint2WalletIntegrationTest {

    @Autowired MockMvc mvc;
    @Autowired JdbcTemplate jdbc;

    private final List<Account> accounts = new ArrayList<>();
    private Account owner;
    private Account other;

    @BeforeEach
    void createAccounts() {
        owner = createAccount();
        other = createAccount();
    }

    @AfterEach
    void removeAccounts() {
        for (Account account : accounts) {
            jdbc.update("DELETE FROM transactions WHERE user_id = ?", account.id());
            jdbc.update("DELETE FROM categories WHERE user_id = ?", account.id());
            jdbc.update("DELETE FROM users WHERE id = ?", account.id());
        }
    }

    @Test
    void defaultCategoriesArePrivateAndCannotBeModified() throws Exception {
        mvc.perform(get("/api/v1/categories")).andExpect(status().isUnauthorized());

        int defaultId = categoryId(owner, "Lương");
        mvc.perform(get("/api/v1/categories").with(user(owner.identifier())))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(8))
                .andExpect(jsonPath("$[0].isSystem").value(true));
        mvc.perform(delete("/api/v1/categories/{id}", defaultId).with(user(owner.identifier())))
                .andExpect(status().isForbidden());
        mvc.perform(delete("/api/v1/categories/{id}", defaultId).with(user(other.identifier())))
                .andExpect(status().isForbidden());
    }

    @Test
    void personalCategoryCannotBeDuplicatedOrDeletedWhileReferenced() throws Exception {
        mvc.perform(post("/api/v1/categories").with(user(owner.identifier()))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"name":"  Học tập  ","type":"EXPENSE"}
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name").value("Học tập"))
                .andExpect(jsonPath("$.isSystem").value(false));
        mvc.perform(post("/api/v1/categories").with(user(owner.identifier()))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"name":"học tập","type":"EXPENSE"}
                                """))
                .andExpect(status().isConflict());

        int id = categoryId(owner, "Học tập");
        jdbc.update("""
                INSERT INTO transactions (user_id, category_id, amount, transaction_date)
                VALUES (?, ?, 50000, CURRENT_DATE)
                """, owner.id(), id);
        mvc.perform(delete("/api/v1/categories/{id}", id).with(user(owner.identifier())))
                .andExpect(status().isConflict());
        mvc.perform(patch("/api/v1/categories/{id}", id).with(user(owner.identifier()))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"name":"Học phí","isActive":false}
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Học phí"))
                .andExpect(jsonPath("$.isActive").value(false));
    }

    @Test
    void walletPatchPersistsOnlyForTheAuthenticatedAccount() throws Exception {
        mvc.perform(get("/api/v1/me").with(user(owner.identifier())))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.currency").value("VND"))
                .andExpect(jsonPath("$.timezone").value("Asia/Saigon"))
                .andExpect(jsonPath("$.openingBalance").value(0.0));
        mvc.perform(patch("/api/v1/me").with(user(owner.identifier()))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"currency":"usd","timezone":"Asia/Tokyo","openingBalance":1250.25}
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.currency").value("USD"));
        mvc.perform(patch("/api/v1/me").with(user(owner.identifier()))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"timezone":"invalid","openingBalance":-1}
                                """))
                .andExpect(status().is(422));
        mvc.perform(get("/api/v1/me").with(user(owner.identifier())))
                .andExpect(jsonPath("$.timezone").value("Asia/Tokyo"))
                .andExpect(jsonPath("$.openingBalance").value(1250.25));
        mvc.perform(get("/api/v1/me").with(user(other.identifier())))
                .andExpect(jsonPath("$.currency").value("VND"))
                .andExpect(jsonPath("$.openingBalance").value(0.0));
    }

    private Account createAccount() {
        String identifier = "sprint2-" + UUID.randomUUID() + "@example.test";
        Integer id = jdbc.queryForObject("""
                INSERT INTO users (identifier, password, full_name)
                VALUES (?, 'test-only', 'Sprint 2') RETURNING id
                """, Integer.class, identifier);
        Account account = new Account(id, identifier);
        accounts.add(account);
        return account;
    }

    private int categoryId(Account account, String name) {
        return jdbc.queryForObject("SELECT id FROM categories WHERE user_id = ? AND name = ?",
                Integer.class, account.id(), name);
    }

    private record Account(int id, String identifier) {}
}
