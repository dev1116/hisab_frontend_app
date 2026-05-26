package com.hisab.quotation.repository;


import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort.Direction;
import java.util.List;
import java.util.Optional;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.hisab.quotation.entity.Quotation;

@Repository
public interface QuotationRepository extends JpaRepository<Quotation, Long> {

    Page<Quotation> findByBusinessIdAndDeletedAtIsNullAndIsLatestTrue(
        Long businessId, Pageable pageable);

    Optional<Quotation> findByIdAndBusinessIdAndDeletedAtIsNull(
        Long id, Long businessId);

    List<Quotation> findByParentIdAndDeletedAtIsNull(Long parentId);

    // for quote number generation
    @Query("SELECT COUNT(q) FROM Quotation q WHERE q.businessId = :businessId")
    Long countByBusinessId(@Param("businessId") Long businessId);

    Page<Quotation> findByBusinessIdAndCustomerIdAndDeletedAtIsNullAndIsLatestTrue(
        Long businessId, Long customerId, Pageable pageable);
}
