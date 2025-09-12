package io.kestra.core.models.tests;

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

import java.time.Duration;
import java.time.Instant;
import java.util.*;

@SuperBuilder(toBuilder = true)
@Getter
@AllArgsConstructor
@NoArgsConstructor
@Introspected
@ToString
@EqualsAndHashCode
@Schema(description = "Test definition for enterprise test management")
public class Test implements DeletedInterface, TenantInterface, HasUID {
    
    @Setter
    @Pattern(regexp = "^[a-z0-9][a-z0-9_-]*")
    @Schema(description = "The tenant identifier", hidden = true)
    private String tenantId;

    @NotNull
    @NotBlank
    @Pattern(regexp = "^[a-zA-Z0-9][a-zA-Z0-9._-]*")
    @Schema(description = "The test unique identifier")
    private String id;

    @NotNull
    @Pattern(regexp = "^[a-z0-9][a-z0-9._-]*")
    @Schema(description = "The test namespace")
    private String namespace;

    @NotNull
    @NotBlank
    @Schema(description = "The test name")
    private String name;

    @Schema(description = "The test description")
    private String description;

    @NotNull
    @Schema(description = "The test type")
    private TestType type;

    @NotNull
    @Schema(description = "The test status")
    @Builder.Default
    private TestStatus status = TestStatus.DRAFT;

    @Schema(description = "Associated flow ID for flow tests")
    private String flowId;

    @Schema(description = "Associated app ID for app tests")
    private String appId;

    @Valid
    @Schema(description = "Test configuration and parameters")
    private Map<String, Object> configuration;

    @Valid
    @Schema(description = "Test assertions and expected results")
    private List<TestAssertion> assertions;

    @Valid
    @Schema(description = "Test setup and teardown scripts")
    private TestSetup setup;

    @Schema(description = "Test tags for categorization")
    private List<String> tags;

    @Schema(description = "Test owner")
    private String owner;

    @Schema(description = "Test suite this test belongs to")
    private String testSuite;

    @Schema(description = "Test priority")
    @Builder.Default
    private TestPriority priority = TestPriority.MEDIUM;

    @Schema(description = "Test timeout duration")
    private Duration timeout;

    @Schema(description = "Number of retry attempts")
    @Builder.Default
    private Integer retryCount = 0;

    @Schema(description = "Creation timestamp")
    @Builder.Default
    private Instant createdAt = Instant.now();

    @Schema(description = "Last update timestamp")
    @Builder.Default
    private Instant updatedAt = Instant.now();

    @NotNull
    @Builder.Default
    @Schema(description = "Whether the test is deleted")
    private final boolean deleted = false;

    @Schema(description = "Last test execution result")
    private TestExecution lastExecution;

    public enum TestType {
        UNIT,
        INTEGRATION,
        FUNCTIONAL,
        PERFORMANCE,
        SECURITY,
        API,
        UI,
        FLOW_VALIDATION,
        DATA_QUALITY,
        CUSTOM
    }

    public enum TestStatus {
        DRAFT,
        ACTIVE,
        INACTIVE,
        ARCHIVED
    }

    public enum TestPriority {
        LOW,
        MEDIUM,
        HIGH,
        CRITICAL
    }

    @SuperBuilder(toBuilder = true)
    @Getter
    @AllArgsConstructor
    @NoArgsConstructor
    @Introspected
    @ToString
    @EqualsAndHashCode
    public static class TestAssertion {
        @NotNull
        @Schema(description = "Assertion type")
        private AssertionType type;

        @NotNull
        @Schema(description = "Expected value or condition")
        private Object expected;

        @Schema(description = "Actual value path or expression")
        private String actualPath;

        @Schema(description = "Assertion description")
        private String description;

        @Schema(description = "Custom assertion script")
        private String script;

        public enum AssertionType {
            EQUALS,
            NOT_EQUALS,
            GREATER_THAN,
            LESS_THAN,
            CONTAINS,
            NOT_CONTAINS,
            REGEX_MATCH,
            JSON_PATH,
            CUSTOM_SCRIPT
        }
    }

    @SuperBuilder(toBuilder = true)
    @Getter
    @AllArgsConstructor
    @NoArgsConstructor
    @Introspected
    @ToString
    @EqualsAndHashCode
    public static class TestSetup {
        @Schema(description = "Setup script to run before test")
        private String setupScript;

        @Schema(description = "Teardown script to run after test")
        private String teardownScript;

        @Schema(description = "Test data setup")
        private Map<String, Object> testData;

        @Schema(description = "Environment variables for test")
        private Map<String, String> environment;

        @Schema(description = "Dependencies to start before test")
        private List<String> dependencies;
    }

    @SuperBuilder(toBuilder = true)
    @Getter
    @AllArgsConstructor
    @NoArgsConstructor
    @Introspected
    @ToString
    @EqualsAndHashCode
    public static class TestExecution {
        @Schema(description = "Execution ID")
        private String executionId;

        @Schema(description = "Execution status")
        private ExecutionStatus status;

        @Schema(description = "Execution start time")
        private Instant startTime;

        @Schema(description = "Execution end time")
        private Instant endTime;

        @Schema(description = "Execution duration")
        private Duration duration;

        @Schema(description = "Test results")
        private List<TestResult> results;

        @Schema(description = "Error message if failed")
        private String errorMessage;

        @Schema(description = "Execution logs")
        private String logs;

        public enum ExecutionStatus {
            RUNNING,
            PASSED,
            FAILED,
            SKIPPED,
            TIMEOUT,
            ERROR
        }
    }

    @SuperBuilder(toBuilder = true)
    @Getter
    @AllArgsConstructor
    @NoArgsConstructor
    @Introspected
    @ToString
    @EqualsAndHashCode
    public static class TestResult {
        @Schema(description = "Assertion that was tested")
        private TestAssertion assertion;

        @Schema(description = "Whether assertion passed")
        private Boolean passed;

        @Schema(description = "Actual value obtained")
        private Object actualValue;

        @Schema(description = "Error message if failed")
        private String errorMessage;

        @Schema(description = "Execution time for this assertion")
        private Duration executionTime;
    }

    @Override
    @JsonIgnore
    public String uid() {
        return Test.uid(this.getTenantId(), this.getNamespace(), this.getId());
    }

    @JsonIgnore
    public static String uid(String tenantId, String namespace, String id) {
        return IdUtils.fromParts(tenantId, namespace, id);
    }

    public Optional<ConstraintViolationException> validateUpdate(Test updated) {
        Set<ConstraintViolation<?>> violations = new HashSet<>();

        if (!updated.getId().equals(this.getId())) {
            violations.add(ManualConstraintViolation.of(
                "Illegal test id update",
                updated,
                Test.class,
                "test.id",
                updated.getId()
            ));
        }

        if (!updated.getNamespace().equals(this.getNamespace())) {
            violations.add(ManualConstraintViolation.of(
                "Illegal namespace update",
                updated,
                Test.class,
                "test.namespace",
                updated.getNamespace()
            ));
        }

        if (!violations.isEmpty()) {
            return Optional.of(new ConstraintViolationException(violations));
        } else {
            return Optional.empty();
        }
    }

    public Test toDeleted() {
        return this.toBuilder()
            .deleted(true)
            .updatedAt(Instant.now())
            .build();
    }

    public Test withStatus(TestStatus status) {
        return this.toBuilder()
            .status(status)
            .updatedAt(Instant.now())
            .build();
    }

    public Test withLastExecution(TestExecution execution) {
        return this.toBuilder()
            .lastExecution(execution)
            .updatedAt(Instant.now())
            .build();
    }
}
