package com.hisab.customer.service;

import com.hisab.business.entity.Business;
import com.hisab.business.repository.BusinessRepository;
import com.hisab.customer.dto.*;
import com.hisab.customer.entity.*;
import com.hisab.customer.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CustomerService {

    private final CustomerRepository customerRepository;
    private final BusinessCustomerRepository businessCustomerRepository;
    private final BusinessRepository businessRepository;

    @Transactional
    public CustomerResponse addCustomer(Long businessId, AddCustomerRequest req) {

        Business business = businessRepository.findById(businessId)
                .orElseThrow(() -> new RuntimeException("Business not found"));

        // Phone se existing customer check — agar pehle se hai to reuse karo
        Customer customer = customerRepository.findByPhone(req.getPhone())
                .orElseGet(() -> customerRepository.save(
                        Customer.builder()
                                .fullName(req.getFullName())
                                .phone(req.getPhone())
                                .email(req.getEmail())
                                .build()
                ));

        // Already is business ka customer hai?
        if (businessCustomerRepository.existsByBusinessAndCustomer(business, customer)) {
            throw new RuntimeException("Customer already exists in this business");
        }

        BusinessCustomer bc = BusinessCustomer.builder()
                .business(business)
                .customer(customer)
                .notes(req.getNotes())
                .build();

        businessCustomerRepository.save(bc);

        return toResponse(customer, bc);
    }

    public Page<CustomerResponse> getCustomers(Long businessId, int page, int size) {

        Business business = businessRepository.findById(businessId)
                .orElseThrow(() -> new RuntimeException("Business not found"));

        Pageable pageable = PageRequest.of(page, size, Sort.by("joinedAt").descending());

        return businessCustomerRepository
                .findByBusiness(business, pageable)
                .map(bc -> toResponse(bc.getCustomer(), bc));
    }

    public CustomerResponse getCustomer(Long businessId, Long customerId) {

        Business business = businessRepository.findById(businessId)
                .orElseThrow(() -> new RuntimeException("Business not found"));

        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new RuntimeException("Customer not found"));

        BusinessCustomer bc = businessCustomerRepository
                .findByBusinessAndCustomer(business, customer)
                .orElseThrow(() -> new RuntimeException("Customer not in this business"));

        return toResponse(customer, bc);
    }

    private CustomerResponse toResponse(Customer c, BusinessCustomer bc) {
        return CustomerResponse.builder()
                .id(c.getId())
                .fullName(c.getFullName())
                .phone(c.getPhone())
                .email(c.getEmail())
                .notes(bc.getNotes())
                .joinedAt(bc.getJoinedAt())
                .build();
    }
}