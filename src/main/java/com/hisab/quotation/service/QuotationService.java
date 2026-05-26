package com.hisab.quotation.service;

import java.time.LocalDate;
import java.time.LocalDateTime;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.hisab.exception.ResourceNotFoundException;
import com.hisab.quotation.dto.QuotationRequestDTO;
import com.hisab.quotation.dto.QuotationResponseDTO;
import com.hisab.quotation.entity.Quotation;
import com.hisab.quotation.enumuration.QuotationStatus;
import com.hisab.quotation.repository.QuotationRepository;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional
public class QuotationService {

    private final QuotationRepository quotationRepository;
    private final FileStorageService fileStorageService;

    /*
     |--------------------------------------------------------------------------
     | CREATE
     |--------------------------------------------------------------------------
     */

    public QuotationResponseDTO create(
            Long businessId,
            QuotationRequestDTO dto,
            MultipartFile pdf
    ) {

        String quoteNumber =
                generateQuoteNumber(businessId);

        Quotation quotation =
                Quotation.create(
                        businessId,
                        dto.getCustomerId(),
                        dto.getCustomerName(),
                        quoteNumber,

                        dto.getTitle(),
                        dto.getDescription(),

                        dto.getAmount(),
                        dto.getTaxAmount(),
                        dto.getTotalAmount(),

                        dto.getValidUntil(),
                        dto.getNotes(),

                        dto.getAddressLine1(),
                        dto.getAddressLine2(),
                        dto.getPincode(),
                        dto.getCity(),
                        dto.getState(),
                        dto.getCountry()
                );

        if (pdf != null && !pdf.isEmpty()) {

            String pdfUrl =
                    fileStorageService.store(
                            pdf,
                            "quotations/" + businessId
                    );

            quotation.updatePdf(
                    pdfUrl,
                    pdf.getOriginalFilename()
            );
        }

        quotationRepository.save(quotation);

        return toDTO(quotation);
    }

    /*
     |--------------------------------------------------------------------------
     | REVISE
     |--------------------------------------------------------------------------
     */

    public QuotationResponseDTO revise(
            Long businessId,
            Long id,
            QuotationRequestDTO dto,
            MultipartFile pdf
    ) {

        Quotation oldQuotation =
                quotationRepository
                        .findByIdAndBusinessIdAndDeletedAtIsNull(
                                id,
                                businessId
                        )
                        .orElseThrow(() ->
                                new ResourceNotFoundException(
                                        "Quotation not found"
                                )
                        );

        oldQuotation.markAsRevised();

        String pdfUrl =
                oldQuotation.getPdfUrl();

        String pdfOriginalName =
                oldQuotation.getPdfOriginalName();

        if (pdf != null && !pdf.isEmpty()) {

            pdfUrl =
                    fileStorageService.store(
                            pdf,
                            "quotations/" + businessId
                    );

            pdfOriginalName =
                    pdf.getOriginalFilename();
        }

        Long rootParentId =
                oldQuotation.getParentId() != null
                        ? oldQuotation.getParentId()
                        : oldQuotation.getId();

        int nextVersion =
                oldQuotation.getVersion() + 1;

        String baseQuoteNumber =
                oldQuotation
                        .getQuoteNumber()
                        .split("-R")[0];

        String revisedQuoteNumber =
                baseQuoteNumber +
                        "-R" +
                        (nextVersion - 1);

        Quotation revisedQuotation =
                Quotation.create(
                        businessId,
                        dto.getCustomerId(),
                        dto.getCustomerName(),
                        revisedQuoteNumber,

                        dto.getTitle(),
                        dto.getDescription(),

                        dto.getAmount(),
                        dto.getTaxAmount(),
                        dto.getTotalAmount(),

                        dto.getValidUntil(),
                        dto.getNotes(),

                        dto.getAddressLine1(),
                        dto.getAddressLine2(),
                        dto.getPincode(),
                        dto.getCity(),
                        dto.getState(),
                        dto.getCountry()
                );

        revisedQuotation.updatePdf(
                pdfUrl,
                pdfOriginalName
        );

        revisedQuotation.makeRevision(
                rootParentId,
                nextVersion
        );

        quotationRepository.save(
                revisedQuotation
        );

        return toDTO(revisedQuotation);
    }

    /*
     |--------------------------------------------------------------------------
     | STATUS UPDATE
     |--------------------------------------------------------------------------
     */

    public QuotationResponseDTO updateStatus(
            Long businessId,
            Long id,
            String status
    ) {

        Quotation quotation =
                quotationRepository
                        .findByIdAndBusinessIdAndDeletedAtIsNull(
                                id,
                                businessId
                        )
                        .orElseThrow(() ->
                                new ResourceNotFoundException(
                                        "Quotation not found"
                                )
                        );

        quotation.changeStatus(
                QuotationStatus.valueOf(
                        status.toUpperCase()
                )
        );

        return toDTO(quotation);
    }

    /*
     |--------------------------------------------------------------------------
     | GET
     |--------------------------------------------------------------------------
     */

    public QuotationResponseDTO get(
            Long businessId,
            Long id
    ) {

        return quotationRepository
                .findByIdAndBusinessIdAndDeletedAtIsNull(
                        id,
                        businessId
                )
                .map(this::toDTO)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Quotation not found"
                        )
                );
    }

    /*
     |--------------------------------------------------------------------------
     | LIST
     |--------------------------------------------------------------------------
     */

    public Page<QuotationResponseDTO> list(
            Long businessId,
            Pageable pageable
    ) {

        return quotationRepository
                .findByBusinessIdAndDeletedAtIsNullAndIsLatestTrue(
                        businessId,
                        pageable
                )
                .map(this::toDTO);
    }

    /*
     |--------------------------------------------------------------------------
     | DELETE
     |--------------------------------------------------------------------------
     */

    public void delete(
            Long businessId,
            Long id
    ) {

        Quotation quotation =
                quotationRepository
                        .findByIdAndBusinessIdAndDeletedAtIsNull(
                                id,
                                businessId
                        )
                        .orElseThrow(() ->
                                new ResourceNotFoundException(
                                        "Quotation not found"
                                )
                        );

        quotation.softDelete();
    }

    /*
     |--------------------------------------------------------------------------
     | PRIVATE METHODS
     |--------------------------------------------------------------------------
     */

    private String generateQuoteNumber(
            Long businessId
    ) {

        long count =
                quotationRepository
                        .countByBusinessId(
                                businessId
                        ) + 1;

        return String.format(
                "QT-%d-%04d",
                LocalDate.now().getYear(),
                count
        );
    }

    private QuotationResponseDTO toDTO(
            Quotation q
    ) {

        return QuotationResponseDTO.builder()
                .id(q.getId())
                .businessId(q.getBusinessId())
                .customerId(q.getCustomerId())
                .customerName(q.getCustomerName())
                .quoteNumber(q.getQuoteNumber())
                .title(q.getTitle())
                .description(q.getDescription())
                .amount(q.getAmount())
                .taxAmount(q.getTaxAmount())
                .totalAmount(q.getTotalAmount())
                .status(q.getStatus().name())
                .pdfUrl(q.getPdfUrl())
                .pdfOriginalName(q.getPdfOriginalName())
                .validUntil(q.getValidUntil())
                .issueDate(q.getIssueDate())
                .version(q.getVersion())
                .parentId(q.getParentId())
                .isLatest(q.getIsLatest())
                .notes(q.getNotes())
                .createdAt(q.getCreatedAt())
                .updatedAt(q.getUpdatedAt())
                .build();
    }
}