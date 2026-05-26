package com.hisab.auth.dto;

import jakarta.validation.constraints.*;
import lombok.*;

@Getter @Setter
public class RegisterRequest {
    @NotBlank(message = "Name required")
    private String fullName;

    @Email(message = "Valid email required")
    @NotBlank
    private String email;

    @NotBlank
    @Size(min = 6, message = "Password min 6 characters")
    private String password;

    private String phone;
}