package com.hisab.business.dto;

import java.time.LocalDateTime;

import com.hisab.business.entity.BusinessType;
import com.hisab.business.entity.BusinessUser.Role;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter @Setter @Builder
public class BusinessResponse {
    private Long id;
    private String businessName;
    private String businessCode;
    private String businessType;
    private String logoUrl;
    private Role myRole;
    private LocalDateTime createdAt;
}