package com.example.backend.category;

import com.example.backend.user.CurrentUser;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/v1/categories")
@Tag(name = "Categories")
public class CategoryController {

    private final CategoryService service;
    private final CurrentUser currentUser;

    public CategoryController(CategoryService service, CurrentUser currentUser) {
        this.service = service;
        this.currentUser = currentUser;
    }

    @GetMapping
    public List<CategoryResponse> list(Principal principal) {
        return service.list(currentUser.require(principal).getId());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CategoryResponse create(Principal principal, @Valid @RequestBody CreateCategory request) {
        return service.create(currentUser.require(principal), request);
    }

    @PatchMapping("/{id}")
    public CategoryResponse update(
            Principal principal, @PathVariable Integer id, @Valid @RequestBody UpdateCategory request) {
        return service.update(currentUser.require(principal).getId(), id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(Principal principal, @PathVariable Integer id) {
        service.delete(currentUser.require(principal).getId(), id);
    }

    public enum CategoryType { INCOME, EXPENSE }

    public record CreateCategory(@NotBlank @Size(max = 100) String name, @NotNull CategoryType type) {}
    public record UpdateCategory(@Size(max = 100) String name, Boolean isActive) {}
    public record CategoryResponse(Integer id, String name, String type, boolean isSystem, boolean isActive) {
        static CategoryResponse from(Category category) {
            return new CategoryResponse(
                    category.getId(), category.getName(), category.getType(), category.isSystem(), category.isActive());
        }
    }
}
