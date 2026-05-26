package com.hisab.business.repository;

import com.hisab.business.entity.BusinessType;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface BusinessTypeRepository extends JpaRepository<BusinessType, Long> {
    List<BusinessType> findByIsActiveTrueOrderByDisplayOrderAsc();
    boolean existsByValue(String value);
}