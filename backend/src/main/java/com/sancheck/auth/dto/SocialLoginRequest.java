package com.sancheck.auth.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class SocialLoginRequest {

    @NotBlank
    private String provider;   // "google"

    @NotBlank
    private String idToken;    // Google ID Token
}
