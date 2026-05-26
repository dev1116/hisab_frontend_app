package com.hisab.business.dto;

import lombok.*;

@Getter @Setter @Builder
public class BusinessTypeResponse {
    private Long id;
    private String value;
    private String label;
    private String iconName;
    private String category;
}