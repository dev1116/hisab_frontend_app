package com.hisab.common.pincode.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.hisab.common.pincode.entity.Pincode;

@Repository
public interface PincodeRepository extends JpaRepository<Pincode, Long> {
    List<Pincode> findTop1ByPincode(String pincode);
}