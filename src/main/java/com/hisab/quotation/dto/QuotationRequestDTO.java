package com.hisab.quotation.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class QuotationRequestDTO {
    @NotNull private Long customerId;      // optional, send null if walk-in
    private String customerName;
    @NotBlank private String title;
    private String description;
    @NotNull @DecimalMin("0.0") private BigDecimal amount;
    private BigDecimal taxAmount;
    @NotNull private BigDecimal totalAmount;
    private LocalDate validUntil;
    private LocalDate issueDate;
    private String notes;
    
    private String addressLine1;
    private String addressLine2;

    private String pincode;
    private String city;
   
    private String state;
    private String country;
    // PDF uploaded separately via multipart
}