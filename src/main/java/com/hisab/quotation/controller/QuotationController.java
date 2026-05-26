package com.hisab.quotation.controller;




import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

import org.springframework.http.MediaType;



import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.hisab.quotation.dto.QuotationRequestDTO;
import com.hisab.quotation.dto.QuotationResponseDTO;
import com.hisab.quotation.service.QuotationService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/business/{businessId}/quotations")
@RequiredArgsConstructor
public class QuotationController {

    private final QuotationService quotationService;
    
    private final ObjectMapper objectMapper;

    
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<QuotationResponseDTO> create(
            @PathVariable Long businessId,
            @RequestPart("data") String data,
            @RequestPart(value = "pdf", required = false) MultipartFile pdf)
            throws Exception {

        QuotationRequestDTO dto =
                objectMapper.readValue(data, QuotationRequestDTO.class);

        return ResponseEntity.ok(
                quotationService.create(businessId, dto, pdf)
        );
    }
    
    @PostMapping(
            value = "/{id}/revise",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ResponseEntity<QuotationResponseDTO> revise(
            @PathVariable Long businessId,
            @PathVariable Long id,
            @RequestPart("data") String data,
            @RequestPart(value = "pdf", required = false) MultipartFile pdf)
            throws Exception {

        QuotationRequestDTO dto =
                objectMapper.readValue(data, QuotationRequestDTO.class);

        return ResponseEntity.ok(
                quotationService.revise(businessId, id, dto, pdf)
        );
    }
//    @PostMapping(value = "/{id}/revise",
//            consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
//public ResponseEntity<QuotationResponseDTO> revise(
//       @PathVariable Long businessId, @PathVariable Long id,
//       @RequestPart("data") @Valid QuotationRequestDTO dto,
//       @RequestPart(value = "pdf", required = false) MultipartFile pdf) {
//    	
//    	 QuotationRequestDTO qDto =
//                 objectMapper.readValue(dto, QuotationRequestDTO.class);
//    	
//   return ResponseEntity.ok(quotationService.revise(businessId, id, qDto, pdf));
//}
//    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
//    public ResponseEntity<QuotationResponseDTO> create(
//            @PathVariable Long businessId,
//            @RequestPart("data") @Valid QuotationRequestDTO dto,
//            @RequestPart(value = "pdf", required = false) MultipartFile pdf) {
//        return ResponseEntity.ok(quotationService.create(businessId, dto, pdf));
//    }

    @GetMapping
    public ResponseEntity<Page<QuotationResponseDTO>> list(
            @PathVariable Long businessId,
            @PageableDefault(size = 20, sort = "createdAt",
                             direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(quotationService.list(businessId, pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<QuotationResponseDTO> get(
            @PathVariable Long businessId, @PathVariable Long id) {
        return ResponseEntity.ok(quotationService.get(businessId, id));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<QuotationResponseDTO> updateStatus(
            @PathVariable Long businessId, @PathVariable Long id,
            @RequestParam String status) {
        return ResponseEntity.ok(quotationService.updateStatus(businessId, id, status));
    }

  

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @PathVariable Long businessId, @PathVariable Long id) {
        quotationService.delete(businessId, id);
        return ResponseEntity.noContent().build();
    }
}
