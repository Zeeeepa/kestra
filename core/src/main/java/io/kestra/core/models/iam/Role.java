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
@ToString
@EqualsAndHashCode
@Schema(description = "Role definition for enterprise identity and access management")
public class Role implements DeletedInterface, TenantInterface, HasUID {
    
    @Setter
    @Pattern(regexp = "^[a-z0-9][a-z0-9_-]*")
    @Schema(description = "The tenant identifier", hidden = true)
    private String tenantId;

    @NotNull
    @NotBlank
    @Pattern(regexp = "^[a-zA-Z0-9][a-zA-Z0-9._-]*")
    @Schema(description = "The role unique identifier")
    private String id;

    @NotNull
    @NotBlank
    @Schema(description = "The role name")
    private String name;

    @Schema(description = "The role description")
    private String description;

    @NotNull
    @Schema(description = "The role type")
    private RoleType type;

    @Schema(description = "Role permissions")
    @Builder.Default
    private List<String> permissionIds = new ArrayList<>();

    @Schema(description = "Parent role IDs for role hierarchy")
    @Builder.Default
    private List<String> parentRoleIds = new ArrayList<>();

    @Valid
    @Schema(description = "Role metadata and custom attributes")
    private Map<String, String> metadata;

    @Schema(description = "Role color for UI display")
    private String color;

    @Schema(description = "Role icon for UI display")
    private String icon;

    @Schema(description = "Role priority for conflict resolution")
    @Builder.Default
    private Integer priority = 0;

    @Schema(description = "Whether this is a system role")
    @Builder.Default
    private Boolean systemRole = false;

    @Schema(description = "Whether this role is active")
    @Builder.Default
    private Boolean active = true;

    @Schema(description = "Role scope restrictions")
    private RoleScope scope;

    @Schema(description = "Creation timestamp")
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Schema(description = "Last update timestamp")
    @Builder.Default
    private Instant updatedAt = Instant.now();

    @NotNull
    @Builder.Default
    @Schema(description = "Whether the role is deleted")
    private final boolean deleted = false;

    public enum RoleType {
        SYSTEM_ADMIN,
        TENANT_ADMIN,
        NAMESPACE_ADMIN,
        DEVELOPER,
        OPERATOR,
        VIEWER,
        CUSTOM
    }

    @SuperBuilder(toBuilder = true)
    @Getter
    @AllArgsConstructor
    @NoArgsConstructor
    @Introspected
    @ToString
    @EqualsAndHashCode
    public static class RoleScope {
        @Schema(description = "Namespace restrictions")
        private List<String> namespaces;

        @Schema(description = "Resource type restrictions")
        private List<String> resourceTypes;

        @Schema(description = "Action restrictions")
        private List<String> actions;

        @Schema(description = "Time-based restrictions")
        private TimeRestriction timeRestriction;

        @Schema(description = "IP address restrictions")
        private List<String> ipRestrictions;

        @SuperBuilder(toBuilder = true)
        @Getter
        @AllArgsConstructor
        @NoArgsConstructor
        @Introspected
        @ToString
        @EqualsAndHashCode
        public static class TimeRestriction {
            @Schema(description = "Start time (HH:mm)")
            private String startTime;

            @Schema(description = "End time (HH:mm)")
            private String endTime;

            @Schema(description = "Allowed days of week (1-7, Monday=1)")
            private List<Integer> daysOfWeek;

            @Schema(description = "Timezone for time restrictions")
            private String timezone;
        }
    }

    @Override
    @JsonIgnore
    public String uid() {
        return Role.uid(this.getTenantId(), this.getId());
    }

    @JsonIgnore
    public static String uid(String tenantId, String id) {
        return IdUtils.fromParts(tenantId, id);
    }

    public Optional<ConstraintViolationException> validateUpdate(Role updated) {
        Set<ConstraintViolation<?>> violations = new HashSet<>();

        if (!updated.getId().equals(this.getId())) {
            violations.add(ManualConstraintViolation.of(
                "Illegal role id update",
                updated,
                Role.class,
                "role.id",
                updated.getId()
            ));
        }

        if (this.systemRole && !updated.getSystemRole()) {
            violations.add(ManualConstraintViolation.of(
                "Cannot change system role to non-system role",
                updated,
                Role.class,
                "role.systemRole",
                updated.getSystemRole()
            ));
        }

        if (!violations.isEmpty()) {
            return Optional.of(new ConstraintViolationException(violations));
        } else {
            return Optional.empty();
        }
    }

    public Role toDeleted() {
        return this.toBuilder()
            .deleted(true)
            .active(false)
            .updatedAt(Instant.now())
            .build();
    }

    public Role withActive(Boolean active) {
        return this.toBuilder()
            .active(active)
            .updatedAt(Instant.now())
            .build();
    }

    public Role withPermissions(List<String> permissionIds) {
        return this.toBuilder()
            .permissionIds(new ArrayList<>(permissionIds))
            .updatedAt(Instant.now())
            .build();
    }

    public Role addPermission(String permissionId) {
        List<String> newPermissions = new ArrayList<>(this.permissionIds);
        if (!newPermissions.contains(permissionId)) {
            newPermissions.add(permissionId);
        }
        return this.toBuilder()
            .permissionIds(newPermissions)
            .updatedAt(Instant.now())
            .build();
    }

    public Role removePermission(String permissionId) {
        List<String> newPermissions = new ArrayList<>(this.permissionIds);
        newPermissions.remove(permissionId);
        return this.toBuilder()
            .permissionIds(newPermissions)
            .updatedAt(Instant.now())
            .build();
    }

    public Role withParentRoles(List<String> parentRoleIds) {
        return this.toBuilder()
            .parentRoleIds(new ArrayList<>(parentRoleIds))
            .updatedAt(Instant.now())
            .build();
    }

    public Role addParentRole(String parentRoleId) {
        List<String> newParentRoles = new ArrayList<>(this.parentRoleIds);
        if (!newParentRoles.contains(parentRoleId)) {
            newParentRoles.add(parentRoleId);
        }
        return this.toBuilder()
            .parentRoleIds(newParentRoles)
            .updatedAt(Instant.now())
            .build();
    }

    public Role removeParentRole(String parentRoleId) {
        List<String> newParentRoles = new ArrayList<>(this.parentRoleIds);
        newParentRoles.remove(parentRoleId);
        return this.toBuilder()
            .parentRoleIds(newParentRoles)
            .updatedAt(Instant.now())
            .build();
    }

    @JsonIgnore
    public boolean isSystemRole() {
        return systemRole != null && systemRole;
    }

    @JsonIgnore
    public boolean isActive() {
        return active != null && active;
    }

    /**
     * Creates default system roles for a tenant
     */
    public static List<Role> createDefaultSystemRoles(String tenantId) {
        return Arrays.asList(
            Role.builder()
                .tenantId(tenantId)
                .id("system-admin")
                .name("System Administrator")
                .description("Full system access with all permissions")
                .type(RoleType.SYSTEM_ADMIN)
                .systemRole(true)
                .priority(1000)
                .build(),
            
            Role.builder()
                .tenantId(tenantId)
                .id("tenant-admin")
                .name("Tenant Administrator")
                .description("Full tenant access with administrative permissions")
                .type(RoleType.TENANT_ADMIN)
                .systemRole(true)
                .priority(900)
                .build(),
            
            Role.builder()
                .tenantId(tenantId)
                .id("developer")
                .name("Developer")
                .description("Development access with flow and execution permissions")
                .type(RoleType.DEVELOPER)
                .systemRole(true)
                .priority(500)
                .build(),
            
            Role.builder()
                .tenantId(tenantId)
                .id("operator")
                .name("Operator")
                .description("Operational access with execution and monitoring permissions")
                .type(RoleType.OPERATOR)
                .systemRole(true)
                .priority(400)
                .build(),
            
            Role.builder()
                .tenantId(tenantId)
                .id("viewer")
                .name("Viewer")
                .description("Read-only access to flows and executions")
                .type(RoleType.VIEWER)
                .systemRole(true)
                .priority(100)
                .build()
        );
    }
}
