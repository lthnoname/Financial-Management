package com.example.backend.category;

import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Integer> {
    Optional<Category> findByIdAndUserId(Integer id, Integer userId);

    List<Category> findByUserIdOrderBySystemDescTypeAscNameAscIdAsc(Integer userId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<Category> findForUpdateByIdAndUserId(Integer id, Integer userId);

    @Query(value = """
            SELECT EXISTS (SELECT 1 FROM transactions WHERE category_id = :id)
                OR EXISTS (SELECT 1 FROM budgets WHERE category_id = :id)
            """, nativeQuery = true)
    boolean isInUse(@Param("id") Integer id);
}
