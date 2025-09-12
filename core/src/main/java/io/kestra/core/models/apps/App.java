package io.kestra.core.models.apps;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonInclude;
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
@Schema(description = "Application definition for enterprise app management")
public class App implements DeletedInterface, TenantInterface, HasUID {
    
    @Setter
    @Pattern(regexp = "^[a-z0-9][a-z0-9_-]*")
    @Schema(description = "The tenant identifier", hidden = true)
    private String tenantId;

    @NotNull
    @NotBlank
    @Pattern(regexp = "^[a-zA-Z0-9][a-zA-Z0-9._-]*")
    @Schema(description = "The application unique identifier")
    private String id;

    @NotNull
    @Pattern(regexp = "^[a-z0-9][a-z0-9._-]*")
    @Schema(description = "The application namespace")
    private String namespace;

    @NotNull
    @NotBlank
    @Schema(description = "The application name")
    private String name;

    @Schema(description = "The application description")
    private String description;

    @NotNull
    @Schema(description = "The application type")
    private AppType type;

    @NotNull
    @Schema(description = "The application status")
    @Builder.Default
    private AppStatus status = AppStatus.DRAFT;

    @Valid
    @Schema(description = "Application configuration")
    private Map<String, Object> configuration;

    @Valid
    @Schema(description = "Application metadata")
    private Map<String, String> metadata;

    @Schema(description = "Associated flow IDs")
    private List<String> flowIds;

    @Schema(description = "Application version")
    @Builder.Default
    private String version = "1.0.0";

    @Schema(description = "Application tags")
    private List<String> tags;

    @Schema(description = "Application owner")
    private String owner;

    @Schema(description = "Creation timestamp")
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Schema(description = "Last update timestamp")
    @Builder.Default
    private Instant updatedAt = Instant.now();

    @NotNull
    @Builder.Default
    @Schema(description = "Whether the application is deleted")
    private final boolean deleted = false;

    @Schema(description = "Application deployment configuration")
    private AppDeployment deployment;

    public enum AppType {
        WEB_APPLICATION,
        API_SERVICE,
        BATCH_JOB,
        MICROSERVICE,
        WORKFLOW,
        DASHBOARD,
        CUSTOM
    }

    public enum AppStatus {
        DRAFT,
        ACTIVE,
        INACTIVE,
        DEPLOYED,
        FAILED,
        ARCHIVED
    }

    @SuperBuilder(toBuilder = true)
    @Getter
    @AllArgsConstructor
    @NoArgsConstructor
    @Introspected
    @ToString
    @EqualsAndHashCode
    public static class AppDeployment {
        @Schema(description = "Deployment environment")
        private String environment;

        @Schema(description = "Deployment URL")
        private String url;

        @Schema(description = "Deployment configuration")
        private Map<String, Object> config;

        @Schema(description = "Health check endpoint")
        private String healthCheckUrl;

        @Schema(description = "Deployment timestamp")
        @Builder.Default
        private Instant deployedAt = Instant.now();

        @Schema(description = "Deployment status")
        @Builder.Default
        private DeploymentStatus status = DeploymentStatus.PENDING;

        public enum DeploymentStatus {
            PENDING,
            DEPLOYING,
            DEPLOYED,
            FAILED,
            ROLLBACK
        }
    }

    @Override
    @JsonIgnore
    public String uid() {
        return App.uid(this.getTenantId(), this.getNamespace(), this.getId());
    }

    @JsonIgnore
    public static String uid(String tenantId, String namespace, String id) {
        return IdUtils.fromParts(tenantId, namespace, id);
    }

    public Optional<ConstraintViolationException> validateUpdate(App updated) {
        Set<ConstraintViolation<?>> violations = new HashSet<>();

        if (!updated.getId().equals(this.getId())) {
            violations.add(ManualConstraintViolation.of(
                "Illegal app id update",
                updated,
                App.class,
                "app.id",
                updated.getId()
            ));
        }

        if (!updated.getNamespace().equals(this.getNamespace())) {
            violations.add(ManualConstraintViolation.of(
                "Illegal namespace update",
                updated,
                App.class,
                "app.namespace",
                updated.getNamespace()
            ));
        }

        if (!violations.isEmpty()) {
            return Optional.of(new ConstraintViolationException(violations));
        } else {
            return Optional.empty();
        }
    }

    public App toDeleted() {
        return this.toBuilder()
            .deleted(true)
            .updatedAt(Instant.now())
            .build();
    }

    public App withStatus(AppStatus status) {
        return this.toBuilder()
            .status(status)
            .updatedAt(Instant.now())
            .build();
    }

    public App withDeployment(AppDeployment deployment) {
        return this.toBuilder()
            .deployment(deployment)
            .updatedAt(Instant.now())
            .build();
    }
}
