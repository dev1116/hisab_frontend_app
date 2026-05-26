package com.hisab.auth.dto;

import lombok.*;

@Getter @Setter @AllArgsConstructor @Builder
public class AuthResponse {
    private String token;
    private String email;
    private String fullName;
    private Long userId;
}