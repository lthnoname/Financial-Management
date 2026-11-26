package com.example.backend.category;

import com.example.backend.category.CategoryController.CategoryResponse;
import com.example.backend.category.CategoryController.CreateCategory;
import com.example.backend.category.CategoryController.UpdateCategory;
import com.example.backend.common.AuthException;
import com.example.backend.user.User;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class CategoryService {

    private final CategoryRepository categories;

    public CategoryService(CategoryRepository categories) {
        this.categories = categories;
    }

    @Transactional(readOnly = true)
    public List<CategoryResponse> list(Integer userId) {
        return categories.findByUserIdOrderBySystemDescTypeAscNameAscIdAsc(userId).stream()
                .map(CategoryResponse::from)
                .toList();
    }

    @Transactional
    public CategoryResponse create(User owner, CreateCategory request) {
        return save(new Category(owner, cleanName(request.name()), request.type().name()));
    }

    @Transactional
    public CategoryResponse update(Integer userId, Integer id, UpdateCategory request) {
        Category category = requirePersonalCategory(userId, id);
        if (request.name() == null && request.isActive() == null) {
            throw new AuthException(HttpStatus.BAD_REQUEST, "Cần cung cấp tên hoặc trạng thái danh mục.");
        }
        if (request.name() != null) {
            category.setName(cleanName(request.name()));
        }
        if (request.isActive() != null) {
            category.setActive(request.isActive());
        }
        return save(category);
    }

    @Transactional
    public void delete(Integer userId, Integer id) {
        Category category = requirePersonalCategory(userId, id);
        if (categories.isInUse(id)) {
            throw categoryInUse();
        }
        try {
            categories.delete(category);
            categories.flush();
        } catch (DataIntegrityViolationException ex) {
            throw categoryInUse();
        }
    }

    private Category requirePersonalCategory(Integer userId, Integer id) {
        Category category = categories.findForUpdateByIdAndUserId(id, userId).orElseThrow(() ->
                categories.existsById(id)
                        ? new AuthException(HttpStatus.FORBIDDEN, "Bạn không có quyền sửa danh mục này.")
                        : new AuthException(HttpStatus.NOT_FOUND, "Không tìm thấy danh mục."));
        if (category.isSystem()) {
            throw new AuthException(HttpStatus.FORBIDDEN, "Không thể sửa hoặc xóa danh mục mặc định.");
        }
        return category;
    }

    private CategoryResponse save(Category category) {
        try {
            return CategoryResponse.from(categories.saveAndFlush(category));
        } catch (DataIntegrityViolationException ex) {
            if (ex.getCause() instanceof org.hibernate.exception.ConstraintViolationException violation
                    && "uq_category_user_type_name".equals(violation.getConstraintName())) {
                throw new AuthException(HttpStatus.CONFLICT, "Tên danh mục đã tồn tại trong loại thu hoặc chi này.");
            }
            throw ex;
        }
    }

    private String cleanName(String name) {
        String cleaned = name.strip();
        if (cleaned.isBlank()) {
            throw new AuthException(HttpStatus.BAD_REQUEST, "Tên danh mục không được để trống.");
        }
        return cleaned;
    }

    private AuthException categoryInUse() {
        return new AuthException(
                HttpStatus.CONFLICT, "Danh mục đang được sử dụng. Bạn có thể vô hiệu hóa danh mục.");
    }
}
