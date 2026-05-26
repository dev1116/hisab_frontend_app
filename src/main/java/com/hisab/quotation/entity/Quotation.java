package com.hisab.quotation.entity;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import com.hisab.quotation.enumuration.QuotationStatus;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "quotations")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Quotation {

    /*
     |--------------------------------------------------------------------------
     | IDENTITY
     |--------------------------------------------------------------------------
     */

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "business_id", nullable = false, updatable = false)
    private Long businessId;

    @Column(name = "customer_id")
    private Long customerId;

    @Column(name = "customer_name", nullable = false)
    private String customerName;

    @Column(
            name = "quote_number",
            nullable = false,
            unique = true,
            updatable = false
    )
    private String quoteNumber;

    /*
     |--------------------------------------------------------------------------
     | CONTENT
     |--------------------------------------------------------------------------
     */

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(
            name = "amount",
            nullable = false,
            precision = 12,
            scale = 2
    )
    private BigDecimal amount;

    @Column(
            name = "tax_amount",
            nullable = false,
            precision = 12,
            scale = 2
    )
    private BigDecimal taxAmount;

    @Column(
            name = "total_amount",
            nullable = false,
            precision = 12,
            scale = 2
    )
    private BigDecimal totalAmount;

    /*
     |--------------------------------------------------------------------------
     | STATUS
     |--------------------------------------------------------------------------
     */

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private QuotationStatus status;

    @Column(name = "is_latest", nullable = false)
    private Boolean isLatest;

    /*
     |--------------------------------------------------------------------------
     | FILES
     |--------------------------------------------------------------------------
     */

    @Column(name = "pdf_url")
    private String pdfUrl;

    @Column(name = "pdf_original_name")
    private String pdfOriginalName;

    /*
     |--------------------------------------------------------------------------
     | DATES
     |--------------------------------------------------------------------------
     */

    @Column(name = "valid_until")
    private LocalDate validUntil;

    @Column(name = "issue_date", nullable = false)
    private LocalDate issueDate;

    /*
     |--------------------------------------------------------------------------
     | VERSIONING
     |--------------------------------------------------------------------------
     */

    @Column(name = "version", nullable = false)
    private Integer version;

    @Column(name = "parent_id")
    private Long parentId;

    /*
     |--------------------------------------------------------------------------
     | ADDRESS
     |--------------------------------------------------------------------------
     */

    @Column(name = "address_line_1")
    private String addressLine1;

    @Column(name = "address_line_2")
    private String addressLine2;

    @Column(name = "pincode")
    private String pincode;

    @Column(name = "city", nullable = false)
    private String city;

    @Column(name = "state")
    private String state;

    @Column(name = "country", nullable = false)
    private String country;

    /*
     |--------------------------------------------------------------------------
     | EXTRA
     |--------------------------------------------------------------------------
     */

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    /*
     |--------------------------------------------------------------------------
     | AUDIT
     |--------------------------------------------------------------------------
     */

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    /*
     |--------------------------------------------------------------------------
     | FACTORY METHOD
     |--------------------------------------------------------------------------
     */

    public static Quotation create(
            Long businessId,
            Long customerId,
            String customerName,
            String quoteNumber,
            String title,
            String description,
            BigDecimal amount,
            BigDecimal taxAmount,
            BigDecimal totalAmount,
            LocalDate validUntil,
            String notes,
            String addressLine1,
            String addressLine2,
            String pincode,
            String city,
            String state,
            String country
    ) {

        validateBusinessId(businessId);
        validateCustomerName(customerName);
        validateQuoteNumber(quoteNumber);
        validateTitle(title);
        validateAmounts(amount, taxAmount, totalAmount);
        validateCity(city);
        validateCountry(country);

        Quotation quotation = new Quotation();

        quotation.businessId = businessId;
        quotation.customerId = customerId;
        quotation.customerName = customerName.trim();
        quotation.quoteNumber = quoteNumber.trim();

        quotation.title = title.trim();
        quotation.description = normalize(description);

        quotation.amount = amount;
        quotation.taxAmount =
                taxAmount != null
                        ? taxAmount
                        : BigDecimal.ZERO;

        quotation.totalAmount = totalAmount;

        quotation.validUntil = validUntil;
        quotation.notes = normalize(notes);

        quotation.addressLine1 =
                normalize(addressLine1);

        quotation.addressLine2 =
                normalize(addressLine2);

        quotation.pincode =
                normalize(pincode);

        quotation.city = city.trim();
        quotation.state = normalize(state);
        quotation.country = country.trim();

        quotation.status =
                QuotationStatus.DRAFT;

        quotation.version = 1;
        quotation.isLatest = true;
        quotation.issueDate = LocalDate.now();

        return quotation;
    }

    /*
     |--------------------------------------------------------------------------
     | REVISION
     |--------------------------------------------------------------------------
     */

    public void makeRevision(
            Long parentId,
            Integer version
    ) {

        if (parentId == null) {
            throw new IllegalArgumentException(
                    "Parent id required"
            );
        }

        if (version == null || version < 1) {
            throw new IllegalArgumentException(
                    "Invalid version"
            );
        }

        this.parentId = parentId;
        this.version = version;
    }

    /*
     |--------------------------------------------------------------------------
     | STATUS METHODS
     |--------------------------------------------------------------------------
     */

    public void markAsRevised() {

        if (this.deletedAt != null) {
            throw new IllegalStateException(
                    "Deleted quotation cannot be revised"
            );
        }

        if (this.status ==
                QuotationStatus.REVISED) {

            throw new IllegalStateException(
                    "Quotation already revised"
            );
        }

        this.status =
                QuotationStatus.REVISED;

        this.isLatest = false;
    }

    public void changeStatus(
            QuotationStatus status
    ) {

        if (status == null) {
            throw new IllegalArgumentException(
                    "Status required"
            );
        }

        this.status = status;
    }

    /*
     |--------------------------------------------------------------------------
     | FILE METHODS
     |--------------------------------------------------------------------------
     */

    public void updatePdf(
            String pdfUrl,
            String pdfOriginalName
    ) {

        this.pdfUrl = normalize(pdfUrl);
        this.pdfOriginalName =
                normalize(pdfOriginalName);
    }

    /*
     |--------------------------------------------------------------------------
     | DELETE
     |--------------------------------------------------------------------------
     */

    public void softDelete() {

        if (this.deletedAt != null) {
            throw new IllegalStateException(
                    "Quotation already deleted"
            );
        }

        this.deletedAt = LocalDateTime.now();
        this.isLatest = false;
    }

    /*
     |--------------------------------------------------------------------------
     | VALIDATION
     |--------------------------------------------------------------------------
     */

    private static void validateBusinessId(
            Long businessId
    ) {

        if (businessId == null) {
            throw new IllegalArgumentException(
                    "Business id required"
            );
        }
    }

    private static void validateCustomerName(
            String customerName
    ) {

        if (customerName == null ||
                customerName.isBlank()) {

            throw new IllegalArgumentException(
                    "Customer name required"
            );
        }
    }

    private static void validateQuoteNumber(
            String quoteNumber
    ) {

        if (quoteNumber == null ||
                quoteNumber.isBlank()) {

            throw new IllegalArgumentException(
                    "Quote number required"
            );
        }
    }

    private static void validateTitle(
            String title
    ) {

        if (title == null ||
                title.isBlank()) {

            throw new IllegalArgumentException(
                    "Title required"
            );
        }
    }

    private static void validateAmounts(
            BigDecimal amount,
            BigDecimal taxAmount,
            BigDecimal totalAmount
    ) {

        if (amount == null ||
                amount.compareTo(
                        BigDecimal.ZERO) < 0) {

            throw new IllegalArgumentException(
                    "Invalid amount"
            );
        }

        if (taxAmount != null &&
                taxAmount.compareTo(
                        BigDecimal.ZERO) < 0) {

            throw new IllegalArgumentException(
                    "Invalid tax amount"
            );
        }

        if (totalAmount == null ||
                totalAmount.compareTo(
                        BigDecimal.ZERO) < 0) {

            throw new IllegalArgumentException(
                    "Invalid total amount"
            );
        }
    }

    private static void validateCity(
            String city
    ) {

        if (city == null ||
                city.isBlank()) {

            throw new IllegalArgumentException(
                    "City required"
            );
        }
    }

    private static void validateCountry(
            String country
    ) {

        if (country == null ||
                country.isBlank()) {

            throw new IllegalArgumentException(
                    "Country required"
            );
        }
    }

    /*
     |--------------------------------------------------------------------------
     | HELPERS
     |--------------------------------------------------------------------------
     */

    private static String normalize(
            String value
    ) {

        if (value == null) {
            return "";
        }

        return value.trim();
    }

    /*
     |--------------------------------------------------------------------------
     | JPA LIFECYCLE
     |--------------------------------------------------------------------------
     */

    @PrePersist
    void prePersist() {

        this.createdAt =
                LocalDateTime.now();

        this.updatedAt =
                LocalDateTime.now();
    }

    @PreUpdate
    void preUpdate() {

        this.updatedAt =
                LocalDateTime.now();
    }
}