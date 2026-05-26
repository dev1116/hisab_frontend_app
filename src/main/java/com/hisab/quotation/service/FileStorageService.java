package com.hisab.quotation.service;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Path;

import org.springframework.beans.factory.annotation.Value;
@Service
public class FileStorageService {

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    public String store(MultipartFile file, String subDir) {
        try {
            String filename = UUID.randomUUID() + "_" + 
                              StringUtils.cleanPath(file.getOriginalFilename());
            Path dir = Paths.get(uploadDir, subDir);
            Files.createDirectories(dir);
            Files.copy(file.getInputStream(), dir.resolve(filename),
                       StandardCopyOption.REPLACE_EXISTING);
            return "/" + uploadDir + "/" + subDir + "/" + filename;
        } catch (IOException e) {
            throw new RuntimeException("File storage failed", e);
        }
    }
}