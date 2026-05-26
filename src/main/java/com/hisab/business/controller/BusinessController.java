package com.hisab.business.controller;

import com.hisab.business.dto.*;
import com.hisab.business.repository.BusinessTypeRepository;
import com.hisab.business.service.BusinessService;
import com.hisab.common.ApiResponse;
import com.hisab.user.entity.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.Map;

@RestController
@RequestMapping("/api/business")
@RequiredArgsConstructor
public class BusinessController {

    private final BusinessService businessService;
    private final BusinessTypeRepository businessTypeRepository;

    @PostMapping
    public ResponseEntity<ApiResponse<BusinessResponse>> create(
            @Valid @RequestBody CreateBusinessRequest request,
            @AuthenticationPrincipal User currentUser) {
        BusinessResponse response = businessService.create(request, currentUser);
        return ResponseEntity.ok(ApiResponse.ok("Business created successfully", response));
    }

    @GetMapping("/my")
    public ResponseEntity<ApiResponse<List<BusinessResponse>>> myBusinesses(
            @AuthenticationPrincipal User currentUser) {
        List<BusinessResponse> list = businessService.getMyBusinesses(currentUser);
        return ResponseEntity.ok(ApiResponse.ok("Businesses fetched", list));
    }

    @GetMapping("/{code}")
    public ResponseEntity<ApiResponse<BusinessResponse>> getByCode(
            @PathVariable String code) {
        BusinessResponse response = businessService.getByCode(code);
        return ResponseEntity.ok(ApiResponse.ok("Business found", response));
    }
    


    @GetMapping("/types")
    public ResponseEntity<ApiResponse<Map<String, List<BusinessTypeResponse>>>> getTypes() {
        List<BusinessTypeResponse> types = businessTypeRepository
                .findByIsActiveTrueOrderByDisplayOrderAsc()
                .stream()
                .map(t -> BusinessTypeResponse.builder()
                        .id(t.getId())
                        .value(t.getValue())
                        .label(t.getLabel())
                        .iconName(t.getIconName())
                        .category(t.getCategory())
                        .build())
                .collect(Collectors.toList());

        // Category wise group karo
        Map<String, List<BusinessTypeResponse>> grouped = types.stream()
                .collect(Collectors.groupingBy(BusinessTypeResponse::getCategory));

        return ResponseEntity.ok(ApiResponse.ok("Business types fetched", grouped));
    }
}