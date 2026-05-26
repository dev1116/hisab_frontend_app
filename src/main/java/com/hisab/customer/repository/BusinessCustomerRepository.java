package com.hisab.customer.repository;

import com.hisab.business.entity.Business;
import com.hisab.customer.entity.BusinessCustomer;
import com.hisab.customer.entity.Customer;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface BusinessCustomerRepository extends JpaRepository<BusinessCustomer, Long> {
    Page<BusinessCustomer> findByBusiness(Business business, Pageable pageable);
    Optional<BusinessCustomer> findByBusinessAndCustomer(Business business, Customer customer);
    boolean existsByBusinessAndCustomer(Business business, Customer customer);
}