package com.hisab.business.repository;

import com.hisab.business.entity.Business;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface BusinessRepository extends JpaRepository<Business, Long> {
    Optional<Business> findByBusinessCodeAndDeletedAtIsNull(String code);
    boolean existsByBusinessCode(String code);
}