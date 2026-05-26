package com.hisab.customer.dto;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
public class CustomerResponse {
    private Long id;
    private String fullName;
    private String phone;
    private String email;
    private String notes;
    private LocalDateTime joinedAt;
}