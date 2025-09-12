package io.kestra.core.models.iam;

import com.fasterxml.jackson.annotation.JsonIgnore;
import io.kestra.core.models.DeletedInterface;
import io.kestra.core.models.HasUID;
import io.kestra.core.models.TenantInterface;
import io.kestra.core.models.validations.ManualConstraintViolation;
import io.kestra.core.utils.IdUtils;
import io.micronaut.core.annotation.Introspected;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.Instant;
import java.util.*;

@SuperBuilder(toBuilder = true)
@Getter
@AllArgsConstructor
@NoArgsConstructor
@Introspected
@ToString(exclude = {"passwordHash", "apiKeys"})
@EqualsAndHashCode(exclude = {"passwordHash", "apiKeys"})
@Schema(description = "User definition for enterprise identity and access management")
public class User implements DeletedInterface, TenantInterface, HasUID {
    
    @Setter
    @Pattern(regexp = "^[a-z0-9][a-z0-9_-]*")
    @Schema(description = "The tenant identifier", hidden = true)
    private String tenantId;

    @NotNull
    @NotBlank
    @Pattern(regexp = "^[a-zA-Z0-9][a-zA-Z0-9._-]*")
    @Schema(description = "The user unique identifier")
    private String id;

    @NotNull
    @NotBlank
    @Schema(description = "The username")
    private String username;

    @NotNull
    @NotBlank
    @Email
    @Schema(description = "The user email address")
    private String email;

    @Schema(description = "The user first name")
    private String firstName;

    @Schema(description = "The user last name")
    private String lastName;

    @Schema(description = "The user display name")
    private String displayName;

    @JsonIgnore
    @Schema(description = "The user password hash", hidden = true)
    private String passwordHash;

    @NotNull
    @Schema(description = "The user status")
    @Builder.Default
    private UserStatus status = UserStatus.ACTIVE;

    @Schema(description = "User roles")
    @Builder.Default
    private List<String> roleIds = new ArrayList<>();

    @Schema(description = "User groups")
    @Builder.Default
    private List<String> groupIds = new ArrayList<>();

    @Valid
    @Schema(description = "User metadata and custom attributes")
    private Map<String, String> metadata;

    @Schema(description = "User avatar URL")
    private String avatarUrl;

    @Schema(description = "User timezone")
    private String timezone;

    @Schema(description = "User locale")
    private String locale;

    @Schema(description = "User phone number")
    private String phoneNumber;

    @Schema(description = "User department")
    private String department;

    @Schema(description = "User job title")
    private String jobTitle;

    @Schema(description = "User manager ID")
    private String managerId;

    @JsonIgnore
    @Schema(description = "User API keys", hidden = true)
    @Builder.Default
    private List<ApiKey> apiKeys = new ArrayList<>();

    @Schema(description = "Last login timestamp")
    private Instant lastLoginAt;

    @Schema(description = "Password last changed timestamp")
    private Instant passwordChangedAt;

    @Schema(description = "Account locked until timestamp")
    private Instant lockedUntil;

    @Schema(description = "Failed login attempts count")
    @Builder.Default
    private Integer failedLoginAttempts = 0;

    @Schema(description = "Whether multi-factor authentication is enabled")
    @Builder.Default
    private Boolean mfaEnabled = false;

    @Schema(description = "Creation timestamp")
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Schema(description = "Last update timestamp")
    @Builder.Default
    private Instant updatedAt = Instant.now();

    @NotNull
    @Builder.Default
    @Schema(description = "Whether the user is deleted")
    private final boolean deleted = false;

    public enum UserStatus {
        ACTIVE,
        INACTIVE,
        SUSPENDED,
        PENDING_ACTIVATION,
        LOCKED
    }

    @SuperBuilder(toBuilder = true)
    @Getter
    @AllArgsConstructor
    @NoArgsConstructor
    @Introspected
    @ToString(exclude = {"keyHash"})
    @EqualsAndHashCode(exclude = {"keyHash"})
    public static class ApiKey {
        @NotNull
        @Schema(description = "API key ID")
        private String id;

        @NotNull
        @Schema(description = "API key name")
        private String name;

        @JsonIgnore
        @Schema(description = "API key hash", hidden = true)
        private String keyHash;

        @Schema(description = "API key permissions")
        private List<String> permissions;

        @Schema(description = "API key expiration timestamp")
        private Instant expiresAt;

        @Schema(description = "Last used timestamp")
        private Instant lastUsedAt;

        @Schema(description = "Whether the API key is active")
        @Builder.Default
        private Boolean active = true;

        @Schema(description = "Creation timestamp")
        @Builder.Default
        private Instant createdAt = Instant.now();
    }

    @Override
    @JsonIgnore
    public String uid() {
        return User.uid(this.getTenantId(), this.getId());
    }

    @JsonIgnore
    public static String uid(String tenantId, String id) {
        return IdUtils.fromParts(tenantId, id);
    }

    @JsonIgnore
    public String getFullName() {
        if (firstName != null && lastName != null) {
            return firstName + " " + lastName;
        } else if (displayName != null) {
            return displayName;
        } else {
            return username;
        }
    }

    @JsonIgnore
    public boolean isLocked() {
        return lockedUntil != null && lockedUntil.isAfter(Instant.now());
    }

    @JsonIgnore
    public boolean isActive() {
        return status == UserStatus.ACTIVE && !isLocked();
    }

    public Optional<ConstraintViolationException> validateUpdate(User updated) {
        Set<ConstraintViolation<?>> violations = new HashSet<>();

        if (!updated.getId().equals(this.getId())) {
            violations.add(ManualConstraintViolation.of(
                "Illegal user id update",
                updated,
                User.class,
                "user.id",
                updated.getId()
            ));
        }

        if (!updated.getUsername().equals(this.getUsername())) {
            violations.add(ManualConstraintViolation.of(
                "Illegal username update",
                updated,
                User.class,
                "user.username",
                updated.getUsername()
            ));
        }

        if (!violations.isEmpty()) {
            return Optional.of(new ConstraintViolationException(violations));
        } else {
            return Optional.empty();
        }
    }

    public User toDeleted() {
        return this.toBuilder()
            .deleted(true)
            .status(UserStatus.INACTIVE)
            .updatedAt(Instant.now())
            .build();
    }

    public User withStatus(UserStatus status) {
        return this.toBuilder()
            .status(status)
            .updatedAt(Instant.now())
            .build();
    }

    public User withLastLogin(Instant lastLoginAt) {
        return this.toBuilder()
            .lastLoginAt(lastLoginAt)
            .failedLoginAttempts(0)
            .lockedUntil(null)
            .updatedAt(Instant.now())
            .build();
    }

    public User withFailedLogin() {
        int attempts = (failedLoginAttempts != null ? failedLoginAttempts : 0) + 1;
        Instant lockUntil = attempts >= 5 ? Instant.now().plusSeconds(300) : null; // Lock for 5 minutes after 5 failed attempts
        
        return this.toBuilder()
            .failedLoginAttempts(attempts)
            .lockedUntil(lockUntil)
            .updatedAt(Instant.now())
            .build();
    }

    public User withPasswordChange(String newPasswordHash) {
        return this.toBuilder()
            .passwordHash(newPasswordHash)
            .passwordChangedAt(Instant.now())
            .updatedAt(Instant.now())
            .build();
    }

    public User withRoles(List<String> roleIds) {
        return this.toBuilder()
            .roleIds(new ArrayList<>(roleIds))
            .updatedAt(Instant.now())
            .build();
    }

    public User addRole(String roleId) {
        List<String> newRoles = new ArrayList<>(this.roleIds);
        if (!newRoles.contains(roleId)) {
            newRoles.add(roleId);
        }
        return this.toBuilder()
            .roleIds(newRoles)
            .updatedAt(Instant.now())
            .build();
    }

    public User removeRole(String roleId) {
        List<String> newRoles = new ArrayList<>(this.roleIds);
        newRoles.remove(roleId);
        return this.toBuilder()
            .roleIds(newRoles)
            .updatedAt(Instant.now())
            .build();
    }
}
