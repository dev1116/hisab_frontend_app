package com.hisab.business.service;

import com.hisab.business.repository.BusinessRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class BusinessCodeGenerator {

    private final BusinessRepository businessRepository;

    public String generate(String businessName) {
        // "Sharma Mart" → "SHARMA-MART"
        String slug = businessName.trim()
                .toUpperCase()
                .replaceAll("[^A-Z0-9 ]", "")
                .replaceAll("\\s+", "-");

        // Max 15 chars for slug
        if (slug.length() > 15) {
            slug = slug.substring(0, 15);
        }

        // Keep trying till unique code milta hai
        String code;
        do {
            String suffix = UUID.randomUUID()
                    .toString()
                    .replace("-", "")
                    .substring(0, 4)
                    .toUpperCase();
            code = slug + "-" + suffix;
        } while (businessRepository.existsByBusinessCode(code));

        return code; // e.g. SHARMA-MART-3K9A
    }
}