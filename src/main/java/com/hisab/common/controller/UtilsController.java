package com.hisab.common.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import com.hisab.common.pincode.entity.Pincode;
import com.hisab.common.pincode.repository.PincodeRepository;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/utils")
@RequiredArgsConstructor
public class UtilsController {

    private final PincodeRepository pincodeRepository;

    @GetMapping("/pincode/{pincode}")
    public ResponseEntity<?> getPincodeDetails(@PathVariable String pincode) {
        List<Pincode> results = pincodeRepository.findTop1ByPincode(pincode);

        if (results.isEmpty()) {
            return ResponseEntity.badRequest().body("Invalid pincode");
        }

        Pincode p = results.get(0);
        Map<String, String> response = new HashMap();
        response.put("city", p.getDistrict());   // District = city
        response.put("state", p.getState());
        response.put("postOffice", p.getPostOfficeName());

        return ResponseEntity.ok(response);
    }
}