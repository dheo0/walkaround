package com.sancheck.auth.controller;

import com.sancheck.auth.dto.AuthResponse;
import com.sancheck.auth.dto.SocialLoginRequest;
import com.sancheck.auth.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /**
     * 소셜 로그인 (Google)
     * Body: { "provider": "google", "idToken": "..." }
     */
    @PostMapping("/social-login")
    public ResponseEntity<AuthResponse> socialLogin(
            @Valid @RequestBody SocialLoginRequest request) {
        return ResponseEntity.ok(authService.socialLogin(request));
    }
}
