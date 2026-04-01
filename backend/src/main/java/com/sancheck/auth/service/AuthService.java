package com.sancheck.auth.service;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.sancheck.auth.dto.AuthResponse;
import com.sancheck.auth.dto.SocialLoginRequest;
import com.sancheck.auth.jwt.JwtProvider;
import com.sancheck.user.entity.User;
import com.sancheck.user.repository.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;

@Slf4j
@Service
public class AuthService {

    private final UserRepository userRepository;
    private final JwtProvider jwtProvider;
    private final GoogleIdTokenVerifier googleVerifier;

    public AuthService(UserRepository userRepository,
                       JwtProvider jwtProvider,
                       @Value("${google.client-id}") String googleClientId) {
        this.userRepository = userRepository;
        this.jwtProvider = jwtProvider;
        this.googleVerifier = new GoogleIdTokenVerifier.Builder(
                new NetHttpTransport(), new GsonFactory())
                .setAudience(Collections.singletonList(googleClientId))
                .build();
    }

    @Transactional
    public AuthResponse socialLogin(SocialLoginRequest request) {
        return switch (request.getProvider().toLowerCase()) {
            case "google" -> loginWithGoogle(request.getIdToken());
            default -> throw new IllegalArgumentException(
                    "지원하지 않는 소셜 로그인 제공자: " + request.getProvider());
        };
    }

    private AuthResponse loginWithGoogle(String idToken) {
        GoogleIdToken.Payload payload = verifyGoogleToken(idToken);
        String providerId = payload.getSubject();
        String email = payload.getEmail();
        String name = (String) payload.get("name");
        String profileImageUrl = (String) payload.get("picture");

        User user = userRepository
                .findByProviderAndProviderId("google", providerId)
                .orElseGet(() -> createUser(email, name, profileImageUrl, "google", providerId));

        // 프로필 정보 업데이트 (이름/사진이 바뀔 수 있으므로)
        user.updateProfile(name, profileImageUrl);

        return buildAuthResponse(user);
    }

    private GoogleIdToken.Payload verifyGoogleToken(String idToken) {
        try {
            GoogleIdToken token = googleVerifier.verify(idToken);
            if (token == null) {
                throw new IllegalArgumentException("유효하지 않은 Google ID Token");
            }
            return token.getPayload();
        } catch (Exception e) {
            log.error("Google 토큰 검증 실패", e);
            throw new IllegalArgumentException("Google 토큰 검증 실패: " + e.getMessage());
        }
    }

    private User createUser(String email, String name, String profileImageUrl,
                             String provider, String providerId) {
        return userRepository.save(User.builder()
                .email(email)
                .name(name)
                .profileImageUrl(profileImageUrl)
                .provider(provider)
                .providerId(providerId)
                .build());
    }

    private AuthResponse buildAuthResponse(User user) {
        String accessToken = jwtProvider.generateAccessToken(user.getId(), user.getEmail());
        String refreshToken = jwtProvider.generateRefreshToken(user.getId());

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .user(AuthResponse.UserInfo.builder()
                        .id(user.getId())
                        .email(user.getEmail())
                        .name(user.getName())
                        .profileImageUrl(user.getProfileImageUrl())
                        .build())
                .build();
    }
}
