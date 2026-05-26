package com.hisab.quotation.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class QuotationResponseDTO {
    private Long id;
    private Long businessId;
    private Long customerId;
    private String customerName;
    private String quoteNumber;
    private String title;
    private String description;
    private BigDecimal amount;
    private BigDecimal taxAmount;
    private BigDecimal totalAmount;
    private String status;
    private String pdfUrl;
    private String pdfOriginalName;
    private LocalDate validUntil;
    private LocalDate issueDate;
    private Integer version;
    private Long parentId;
    private Boolean isLatest;
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    private String addressLine1;
    private String addressLine2;

    private String pincode;
    private String city;
   
    private String state;
    private String country;
}