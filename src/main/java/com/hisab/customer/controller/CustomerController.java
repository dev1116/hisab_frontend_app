package com.hisab.customer.controller;

import com.hisab.common.ApiResponse;
import com.hisab.customer.dto.*;
import com.hisab.customer.service.CustomerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/business/{businessId}/customers")
@RequiredArgsConstructor
public class CustomerController {

    private final CustomerService customerService;

    @PostMapping
    public ResponseEntity<ApiResponse<CustomerResponse>> add(
            @PathVariable Long businessId,
            @Valid @RequestBody AddCustomerRequest request) {
        CustomerResponse response = customerService.addCustomer(businessId, request);
        return ResponseEntity.ok(ApiResponse.ok("Customer added", response));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<Page<CustomerResponse>>> list(
            @PathVariable Long businessId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<CustomerResponse> customers = customerService.getCustomers(businessId, page, size);
        return ResponseEntity.ok(ApiResponse.ok("Customers fetched", customers));
    }

    @GetMapping("/{customerId}")
    public ResponseEntity<ApiResponse<CustomerResponse>> get(
            @PathVariable Long businessId,
            @PathVariable Long customerId) {
        CustomerResponse response = customerService.getCustomer(businessId, customerId);
        return ResponseEntity.ok(ApiResponse.ok("Customer fetched", response));
    }
}