package com.hisab.business.repository;

import com.hisab.business.entity.Business;
import com.hisab.business.entity.BusinessUser;
import com.hisab.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface BusinessUserRepository extends JpaRepository<BusinessUser, Long> {
    List<BusinessUser> findByUser(User user);
    boolean existsByBusinessAndUser(Business business, User user);
}