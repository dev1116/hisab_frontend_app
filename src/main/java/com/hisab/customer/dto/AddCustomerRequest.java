package com.hisab.customer.dto;

import jakarta.validation.constraints.*;
import lombok.*;

@Getter @Setter
public class AddCustomerRequest {

    @NotBlank(message = "Name required")
    private String fullName;

    @NotBlank(message = "Phone required")
    @Pattern(regexp = "^[6-9]\\d{9}$", message = "Valid Indian phone number required")
    private String phone;

    private String email;
    private String notes;
}