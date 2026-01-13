package com.medinsights.gateway.config;

import org.springframework.security.oauth2.core.OAuth2Error;
import org.springframework.security.oauth2.core.OAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2TokenValidatorResult;
import org.springframework.security.oauth2.jwt.Jwt;

/**
 * Validates the "aud" (audience) claim of an Auth0 JWT token.
 * Auth0 includes the API identifier as an audience claim.
 */
public class AudienceValidator implements OAuth2TokenValidator<Jwt> {

    private final String audience;
    private final OAuth2Error error = new OAuth2Error(
        "invalid_token",
        "The required audience is missing",
        null
    );

    public AudienceValidator(String audience) {
        this.audience = audience;
    }

    @Override
    public OAuth2TokenValidatorResult validate(Jwt jwt) {
        if (jwt.getAudience().contains(audience)) {
            return OAuth2TokenValidatorResult.success();
        }
        return OAuth2TokenValidatorResult.failure(error);
    }
}
