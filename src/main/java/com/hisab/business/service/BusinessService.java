package com.hisab.business.service;

import com.hisab.business.dto.*;
import com.hisab.business.entity.*;
import com.hisab.business.repository.*;
import com.hisab.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BusinessService {

    private final BusinessRepository businessRepository;
    private final BusinessUserRepository businessUserRepository;
    private final BusinessCodeGenerator codeGenerator;

    @Transactional
    public BusinessResponse create(CreateBusinessRequest req, User currentUser) {
        String code = codeGenerator.generate(req.getBusinessName());

        Business business = Business.builder()
                .businessName(req.getBusinessName())
                .businessCode(code)
                .businessType(req.getBusinessType())
                .createdBy(currentUser)
                .build();

        businessRepository.save(business);

        // Owner ke roop mein add karo
        BusinessUser businessUser = BusinessUser.builder()
                .business(business)
                .user(currentUser)
                .role(BusinessUser.Role.OWNER)
                .build();

        businessUserRepository.save(businessUser);

        return toResponse(business, BusinessUser.Role.OWNER);
    }

    public List<BusinessResponse> getMyBusinesses(User currentUser) {
        return businessUserRepository.findByUser(currentUser)
                .stream()
                .map(bu -> toResponse(bu.getBusiness(), bu.getRole()))
                .collect(Collectors.toList());
    }

    public BusinessResponse getByCode(String code) {
        Business business = businessRepository
                .findByBusinessCodeAndDeletedAtIsNull(code)
                .orElseThrow(() -> new RuntimeException("Business not found with code: " + code));
        return toResponse(business, null);
    }

    private BusinessResponse toResponse(Business b, BusinessUser.Role role) {
        return BusinessResponse.builder()
                .id(b.getId())
                .businessName(b.getBusinessName())
                .businessCode(b.getBusinessCode())
                .businessType(b.getBusinessType())
                .logoUrl(b.getLogoUrl())
                .myRole(role)
                .createdAt(b.getCreatedAt())
                .build();
    }
}