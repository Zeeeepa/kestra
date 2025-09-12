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
@Schema(description = "Permission definition for enterprise identity and access management")
public class Permission implements DeletedInterface, TenantInterface, HasUID {
    
    @Setter
    @Pattern(regexp = "^[a-z0-9][a-z0-9_-]*")
    @Schema(description = "The tenant identifier", hidden = true)
    private String tenantId;

    @NotNull
    @NotBlank
    @Pattern(regexp = "^[a-zA-Z0-9][a-zA-Z0-9._:-]*")
    @Schema(description = "The permission unique identifier")
    private String id;

    @NotNull
    @NotBlank
    @Schema(description = "The permission name")
    private String name;

    @Schema(description = "The permission description")
    private String description;

    @NotNull
    @Schema(description = "The resource type this permission applies to")
    private String resourceType;

    @NotNull
    @Schema(description = "The action this permission allows")
    private String action;

    @Schema(description = "The permission scope")
    private PermissionScope scope;

    @Schema(description = "Whether this is a system permission")
    @Builder.Default
    private Boolean systemPermission = false;

    @Schema(description = "Permission category for grouping")
    private String category;

    @Schema(description = "Permission tags")
    private List<String> tags;

    @Valid
    @Schema(description = "Permission metadata")
    private Map<String, String> metadata;

    @Schema(description = "Creation timestamp")
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Schema(description = "Last update timestamp")
    @Builder.Default
    private Instant updatedAt = Instant.now();

    @NotNull
    @Builder.Default
    @Schema(description = "Whether the permission is deleted")
    private final boolean deleted = false;

    public enum PermissionScope {
        GLOBAL,      // Applies to all resources of the type
        TENANT,      // Applies to tenant-scoped resources
        NAMESPACE,   // Applies to namespace-scoped resources
        RESOURCE     // Applies to specific resource instances
    }

    @Override
    @JsonIgnore
    public String uid() {
        return Permission.uid(this.getTenantId(), this.getId());
    }

    @JsonIgnore
    public static String uid(String tenantId, String id) {
        return IdUtils.fromParts(tenantId, id);
    }

    public Optional<ConstraintViolationException> validateUpdate(Permission updated) {
        Set<ConstraintViolation<?>> violations = new HashSet<>();

        if (!updated.getId().equals(this.getId())) {
            violations.add(ManualConstraintViolation.of(
                "Illegal permission id update",
                updated,
                Permission.class,
                "permission.id",
                updated.getId()
            ));
        }

        if (this.systemPermission && !updated.getSystemPermission()) {
            violations.add(ManualConstraintViolation.of(
                "Cannot change system permission to non-system permission",
                updated,
                Permission.class,
                "permission.systemPermission",
                updated.getSystemPermission()
            ));
        }

        if (!violations.isEmpty()) {
            return Optional.of(new ConstraintViolationException(violations));
        } else {
            return Optional.empty();
        }
    }

    public Permission toDeleted() {
        return this.toBuilder()
            .deleted(true)
            .updatedAt(Instant.now())
            .build();
    }

    @JsonIgnore
    public boolean isSystemPermission() {
        return systemPermission != null && systemPermission;
    }

    /**
     * Creates default system permissions for a tenant
     */
    public static List<Permission> createDefaultSystemPermissions(String tenantId) {
        List<Permission> permissions = new ArrayList<>();
        
        // Flow permissions
        permissions.addAll(createResourcePermissions(tenantId, "flow", "Flow", Arrays.asList(
            "create", "read", "update", "delete", "execute", "validate"
        )));
        
        // Execution permissions
        permissions.addAll(createResourcePermissions(tenantId, "execution", "Execution", Arrays.asList(
            "read", "create", "update", "delete", "restart", "kill"
        )));
        
        // Template permissions
        permissions.addAll(createResourcePermissions(tenantId, "template", "Template", Arrays.asList(
            "create", "read", "update", "delete"
        )));
        
        // Namespace permissions
        permissions.addAll(createResourcePermissions(tenantId, "namespace", "Namespace", Arrays.asList(
            "create", "read", "update", "delete", "manage"
        )));
        
        // App permissions
        permissions.addAll(createResourcePermissions(tenantId, "app", "Application", Arrays.asList(
            "create", "read", "update", "delete", "deploy", "manage"
        )));
        
        // Test permissions
        permissions.addAll(createResourcePermissions(tenantId, "test", "Test", Arrays.asList(
            "create", "read", "update", "delete", "execute", "manage"
        )));
        
        // IAM permissions
        permissions.addAll(createResourcePermissions(tenantId, "user", "User", Arrays.asList(
            "create", "read", "update", "delete", "manage"
        )));
        
        permissions.addAll(createResourcePermissions(tenantId, "role", "Role", Arrays.asList(
            "create", "read", "update", "delete", "assign", "manage"
        )));
        
        permissions.addAll(createResourcePermissions(tenantId, "permission", "Permission", Arrays.asList(
            "create", "read", "update", "delete", "manage"
        )));
        
        // Audit permissions
        permissions.addAll(createResourcePermissions(tenantId, "audit", "Audit Log", Arrays.asList(
            "read", "export", "manage"
        )));
        
        // Instance permissions
        permissions.addAll(createResourcePermissions(tenantId, "instance", "Instance", Arrays.asList(
            "read", "monitor", "manage"
        )));
        
        // Blueprint permissions
        permissions.addAll(createResourcePermissions(tenantId, "blueprint", "Blueprint", Arrays.asList(
            "create", "read", "update", "delete", "publish", "manage"
        )));
        
        // System permissions
        permissions.add(Permission.builder()
            .tenantId(tenantId)
            .id("system:admin")
            .name("System Administration")
            .description("Full system administration access")
            .resourceType("system")
            .action("admin")
            .scope(PermissionScope.GLOBAL)
            .systemPermission(true)
            .category("System")
            .build());
        
        permissions.add(Permission.builder()
            .tenantId(tenantId)
            .id("tenant:admin")
            .name("Tenant Administration")
            .description("Full tenant administration access")
            .resourceType("tenant")
            .action("admin")
            .scope(PermissionScope.TENANT)
            .systemPermission(true)
            .category("System")
            .build());
        
        return permissions;
    }
    
    private static List<Permission> createResourcePermissions(String tenantId, String resourceType, String resourceName, List<String> actions) {
        List<Permission> permissions = new ArrayList<>();
        
        for (String action : actions) {
            permissions.add(Permission.builder()
                .tenantId(tenantId)
                .id(resourceType + ":" + action)
                .name(resourceName + " " + capitalize(action))
                .description(capitalize(action) + " " + resourceName.toLowerCase() + "s")
                .resourceType(resourceType)
                .action(action)
                .scope(PermissionScope.NAMESPACE)
                .systemPermission(true)
                .category(capitalize(resourceType))
                .build());
        }
        
        return permissions;
    }
    
    private static String capitalize(String str) {
        if (str == null || str.isEmpty()) {
            return str;
        }
        return str.substring(0, 1).toUpperCase() + str.substring(1);
    }

    /**
     * Check if this permission matches a resource and action
     */
    public boolean matches(String resourceType, String action) {
        return this.resourceType.equals(resourceType) && this.action.equals(action);
    }

    /**
     * Check if this permission matches a resource, action, and scope
     */
    public boolean matches(String resourceType, String action, PermissionScope scope) {
        return matches(resourceType, action) && this.scope == scope;
    }
}
