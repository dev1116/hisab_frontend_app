package com.hisab.business.dto;

import com.hisab.business.entity.BusinessType;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class CreateBusinessRequest {

    @NotBlank(message = "Business name required")
    @Size(min = 3, max = 100)
    private String businessName;

    @NotNull(message = "Business type required")
    private String businessType;
}