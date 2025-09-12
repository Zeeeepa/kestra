package io.kestra.core.models.blueprints;

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
@Schema(description = "Custom blueprint definition for enterprise workflow templates")
public class CustomBlueprint implements DeletedInterface, TenantInterface, HasUID {
    
    @Setter
    @Pattern(regexp = "^[a-z0-9][a-z0-9_-]*")
    @Schema(description = "The tenant identifier", hidden = true)
    private String tenantId;

    @NotNull
    @NotBlank
    @Pattern(regexp = "^[a-zA-Z0-9][a-zA-Z0-9._-]*")
    @Schema(description = "The blueprint unique identifier")
    private String id;

    @NotNull
    @Pattern(regexp = "^[a-z0-9][a-z0-9._-]*")
    @Schema(description = "The blueprint namespace")
    private String namespace;

    @NotNull
    @NotBlank
    @Schema(description = "The blueprint name")
    private String name;

    @Schema(description = "The blueprint description")
    private String description;

    @NotNull
    @Schema(description = "The blueprint category")
    private BlueprintCategory category;

    @NotNull
    @Schema(description = "The blueprint visibility")
    @Builder.Default
    private BlueprintVisibility visibility = BlueprintVisibility.PRIVATE;

    @NotNull
    @Schema(description = "The blueprint status")
    @Builder.Default
    private BlueprintStatus status = BlueprintStatus.DRAFT;

    @NotNull
    @NotBlank
    @Schema(description = "The blueprint source code (YAML)")
    private String source;

    @Schema(description = "Blueprint version")
    @Builder.Default
    private String version = "1.0.0";

    @Schema(description = "Blueprint tags for categorization")
    private List<String> tags;

    @Schema(description = "Blueprint author")
    private String author;

    @Schema(description = "Blueprint author email")
    private String authorEmail;

    @Schema(description = "Blueprint license")
    private String license;

    @Schema(description = "Blueprint documentation URL")
    private String documentationUrl;

    @Schema(description = "Blueprint repository URL")
    private String repositoryUrl;

    @Valid
    @Schema(description = "Blueprint metadata")
    private Map<String, String> metadata;

    @Valid
    @Schema(description = "Blueprint parameters for customization")
    private List<BlueprintParameter> parameters;

    @Schema(description = "Blueprint icon URL")
    private String iconUrl;

    @Schema(description = "Blueprint screenshot URLs")
    private List<String> screenshots;

    @Schema(description = "Blueprint usage count")
    @Builder.Default
    private Long usageCount = 0L;

    @Schema(description = "Blueprint rating (1-5)")
    private Double rating;

    @Schema(description = "Number of ratings")
    @Builder.Default
    private Integer ratingCount = 0;

    @Schema(description = "Blueprint download count")
    @Builder.Default
    private Long downloadCount = 0L;

    @Schema(description = "Blueprint fork count")
    @Builder.Default
    private Integer forkCount = 0;

    @Schema(description = "Parent blueprint ID if this is a fork")
    private String parentBlueprintId;

    @Schema(description = "Blueprint validation results")
    private BlueprintValidation validation;

    @Schema(description = "Creation timestamp")
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Schema(description = "Last update timestamp")
    @Builder.Default
    private Instant updatedAt = Instant.now();

    @Schema(description = "Publication timestamp")
    private Instant publishedAt;

    @NotNull
    @Builder.Default
    @Schema(description = "Whether the blueprint is deleted")
    private final boolean deleted = false;

    public enum BlueprintCategory {
        DATA_PROCESSING,
        ETL,
        MONITORING,
        AUTOMATION,
        INTEGRATION,
        ANALYTICS,
        MACHINE_LEARNING,
        DEVOPS,
        SECURITY,
        TESTING,
        NOTIFICATION,
        CUSTOM
    }

    public enum BlueprintVisibility {
        PRIVATE,     // Only visible to the author and tenant
        TENANT,      // Visible to all users in the tenant
        PUBLIC       // Visible to all users (if enabled)
    }

    public enum BlueprintStatus {
        DRAFT,
        PUBLISHED,
        DEPRECATED,
        ARCHIVED
    }

    @SuperBuilder(toBuilder = true)
    @Getter
    @AllArgsConstructor
    @NoArgsConstructor
    @Introspected
    @ToString
    @EqualsAndHashCode
    public static class BlueprintParameter {
        @NotNull
        @Schema(description = "Parameter name")
        private String name;

        @NotNull
        @Schema(description = "Parameter type")
        private ParameterType type;

        @Schema(description = "Parameter description")
        private String description;

        @Schema(description = "Default value")
        private Object defaultValue;

        @Schema(description = "Whether parameter is required")
        @Builder.Default
        private Boolean required = false;

        @Schema(description = "Parameter validation pattern")
        private String pattern;

        @Schema(description = "Minimum value (for numeric types)")
        private Double minValue;

        @Schema(description = "Maximum value (for numeric types)")
        private Double maxValue;

        @Schema(description = "Allowed values (for enum types)")
        private List<String> allowedValues;

        @Schema(description = "Parameter example")
        private String example;

        public enum ParameterType {
            STRING,
            INTEGER,
            DOUBLE,
            BOOLEAN,
            ARRAY,
            OBJECT,
            ENUM
        }
    }

    @SuperBuilder(toBuilder = true)
    @Getter
    @AllArgsConstructor
    @NoArgsConstructor
    @Introspected
    @ToString
    @EqualsAndHashCode
    public static class BlueprintValidation {
        @Schema(description = "Whether the blueprint is valid")
        private Boolean valid;

        @Schema(description = "Validation timestamp")
        @Builder.Default
        private Instant validatedAt = Instant.now();

        @Schema(description = "Validation errors")
        private List<String> errors;

        @Schema(description = "Validation warnings")
        private List<String> warnings;

        @Schema(description = "Validation details")
        private String details;

        @JsonIgnore
        public boolean isValid() {
            return valid != null && valid && (errors == null || errors.isEmpty());
        }

        @JsonIgnore
        public boolean hasWarnings() {
            return warnings != null && !warnings.isEmpty();
        }
    }

    @Override
    @JsonIgnore
    public String uid() {
        return CustomBlueprint.uid(this.getTenantId(), this.getNamespace(), this.getId());
    }

    @JsonIgnore
    public static String uid(String tenantId, String namespace, String id) {
        return IdUtils.fromParts(tenantId, namespace, id);
    }

    public Optional<ConstraintViolationException> validateUpdate(CustomBlueprint updated) {
        Set<ConstraintViolation<?>> violations = new HashSet<>();

        if (!updated.getId().equals(this.getId())) {
            violations.add(ManualConstraintViolation.of(
                "Illegal blueprint id update",
                updated,
                CustomBlueprint.class,
                "blueprint.id",
                updated.getId()
            ));
        }

        if (!updated.getNamespace().equals(this.getNamespace())) {
            violations.add(ManualConstraintViolation.of(
                "Illegal namespace update",
                updated,
                CustomBlueprint.class,
                "blueprint.namespace",
                updated.getNamespace()
            ));
        }

        if (!violations.isEmpty()) {
            return Optional.of(new ConstraintViolationException(violations));
        } else {
            return Optional.empty();
        }
    }

    public CustomBlueprint toDeleted() {
        return this.toBuilder()
            .deleted(true)
            .status(BlueprintStatus.ARCHIVED)
            .updatedAt(Instant.now())
            .build();
    }

    public CustomBlueprint withStatus(BlueprintStatus status) {
        CustomBlueprintBuilder<?, ?> builder = this.toBuilder()
            .status(status)
            .updatedAt(Instant.now());
        
        if (status == BlueprintStatus.PUBLISHED && this.publishedAt == null) {
            builder.publishedAt(Instant.now());
        }
        
        return builder.build();
    }

    public CustomBlueprint withSource(String source) {
        return this.toBuilder()
            .source(source)
            .updatedAt(Instant.now())
            .build();
    }

    public CustomBlueprint withValidation(BlueprintValidation validation) {
        return this.toBuilder()
            .validation(validation)
            .updatedAt(Instant.now())
            .build();
    }

    public CustomBlueprint incrementUsage() {
        return this.toBuilder()
            .usageCount(this.usageCount + 1)
            .build();
    }

    public CustomBlueprint incrementDownload() {
        return this.toBuilder()
            .downloadCount(this.downloadCount + 1)
            .build();
    }

    public CustomBlueprint addRating(double rating) {
        double newRating;
        int newCount = this.ratingCount + 1;
        
        if (this.rating == null) {
            newRating = rating;
        } else {
            newRating = ((this.rating * this.ratingCount) + rating) / newCount;
        }
        
        return this.toBuilder()
            .rating(newRating)
            .ratingCount(newCount)
            .build();
    }

    public CustomBlueprint fork(String newId, String newNamespace, String author, String authorEmail) {
        return this.toBuilder()
            .id(newId)
            .namespace(newNamespace)
            .author(author)
            .authorEmail(authorEmail)
            .parentBlueprintId(this.id)
            .status(BlueprintStatus.DRAFT)
            .visibility(BlueprintVisibility.PRIVATE)
            .usageCount(0L)
            .downloadCount(0L)
            .rating(null)
            .ratingCount(0)
            .forkCount(0)
            .publishedAt(null)
            .createdAt(Instant.now())
            .updatedAt(Instant.now())
            .build();
    }

    @JsonIgnore
    public boolean isPublished() {
        return status == BlueprintStatus.PUBLISHED;
    }

    @JsonIgnore
    public boolean isPublic() {
        return visibility == BlueprintVisibility.PUBLIC;
    }

    @JsonIgnore
    public boolean isFork() {
        return parentBlueprintId != null;
    }

    @JsonIgnore
    public boolean isValid() {
        return validation != null && validation.isValid();
    }

    @JsonIgnore
    public String getDisplayName() {
        return name != null ? name : id;
    }

    @JsonIgnore
    public String getFullName() {
        return namespace + "." + id;
    }
}
