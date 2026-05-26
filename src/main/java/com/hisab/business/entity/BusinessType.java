package com.hisab.business.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "business_types")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BusinessType {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String value;

    @Column(nullable = false)
    private String label;

    private String iconName;
    private String category;
    private Boolean isActive;
    private Integer displayOrder;
}