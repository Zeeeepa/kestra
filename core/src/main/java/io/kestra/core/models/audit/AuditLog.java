package io.kestra.core.models.audit;

import com.fasterxml.jackson.annotation.JsonIgnore;
import io.kestra.core.models.HasUID;
import io.kestra.core.models.TenantInterface;
import io.kestra.core.utils.IdUtils;
import io.micronaut.core.annotation.Introspected;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.Instant;
import java.util.Map;

@SuperBuilder(toBuilder = true)
@Getter
@AllArgsConstructor
@NoArgsConstructor
@Introspected
@ToString
@EqualsAndHashCode
@Schema(description = "Audit log entry for enterprise compliance and monitoring")
public class AuditLog implements TenantInterface, HasUID {
    
    @Setter
    @Pattern(regexp = "^[a-z0-9][a-z0-9_-]*")
    @Schema(description = "The tenant identifier", hidden = true)
    private String tenantId;

    @NotNull
    @NotBlank
    @Schema(description = "The audit log unique identifier")
    private String id;

    @NotNull
    @Schema(description = "The timestamp when the event occurred")
    @Builder.Default
    private Instant timestamp = Instant.now();

    @NotNull
    @Schema(description = "The event type")
    private EventType eventType;

    @NotNull
    @Schema(description = "The event category")
    private EventCategory category;

    @NotNull
    @Schema(description = "The event action")
    private String action;

    @Schema(description = "The resource type affected")
    private String resourceType;

    @Schema(description = "The resource ID affected")
    private String resourceId;

    @Schema(description = "The namespace of the resource")
    private String namespace;

    @Schema(description = "The user who performed the action")
    private String userId;

    @Schema(description = "The username who performed the action")
    private String username;

    @Schema(description = "The session ID")
    private String sessionId;

    @Schema(description = "The IP address of the user")
    private String ipAddress;

    @Schema(description = "The user agent")
    private String userAgent;

    @Schema(description = "The event result")
    @Builder.Default
    private EventResult result = EventResult.SUCCESS;

    @Schema(description = "The event severity level")
    @Builder.Default
    private SeverityLevel severity = SeverityLevel.INFO;

    @Schema(description = "Event description")
    private String description;

    @Schema(description = "Error message if the event failed")
    private String errorMessage;

    @Valid
    @Schema(description = "Additional event details")
    private Map<String, Object> details;

    @Valid
    @Schema(description = "Resource state before the change")
    private Map<String, Object> beforeState;

    @Valid
    @Schema(description = "Resource state after the change")
    private Map<String, Object> afterState;

    @Schema(description = "The execution ID if related to an execution")
    private String executionId;

    @Schema(description = "The flow ID if related to a flow")
    private String flowId;

    @Schema(description = "The app ID if related to an app")
    private String appId;

    @Schema(description = "The test ID if related to a test")
    private String testId;

    @Schema(description = "Event tags for categorization")
    private java.util.List<String> tags;

    @Schema(description = "Event correlation ID for tracking related events")
    private String correlationId;

    @Schema(description = "Parent event ID for hierarchical events")
    private String parentEventId;

    @Schema(description = "Event duration in milliseconds")
    private Long durationMs;

    @Schema(description = "Whether this event is sensitive and should be handled carefully")
    @Builder.Default
    private Boolean sensitive = false;

    @Schema(description = "Retention period for this audit log in days")
    private Integer retentionDays;

    public enum EventType {
        AUTHENTICATION,
        AUTHORIZATION,
        RESOURCE_ACCESS,
        RESOURCE_MODIFICATION,
        SYSTEM_EVENT,
        SECURITY_EVENT,
        COMPLIANCE_EVENT,
        PERFORMANCE_EVENT,
        ERROR_EVENT,
        CUSTOM
    }

    public enum EventCategory {
        // Authentication & Authorization
        LOGIN,
        LOGOUT,
        PASSWORD_CHANGE,
        MFA_EVENT,
        PERMISSION_GRANT,
        PERMISSION_REVOKE,
        
        // Resource Management
        CREATE,
        READ,
        UPDATE,
        DELETE,
        EXECUTE,
        DEPLOY,
        
        // System Events
        SYSTEM_START,
        SYSTEM_STOP,
        CONFIGURATION_CHANGE,
        BACKUP,
        RESTORE,
        
        // Security Events
        SECURITY_VIOLATION,
        SUSPICIOUS_ACTIVITY,
        DATA_BREACH,
        VULNERABILITY_DETECTED,
        
        // Compliance Events
        DATA_EXPORT,
        DATA_RETENTION,
        AUDIT_EXPORT,
        COMPLIANCE_CHECK,
        
        // Performance Events
        PERFORMANCE_DEGRADATION,
        RESOURCE_EXHAUSTION,
        SCALING_EVENT,
        
        // Custom Events
        CUSTOM
    }

    public enum EventResult {
        SUCCESS,
        FAILURE,
        PARTIAL_SUCCESS,
        CANCELLED,
        TIMEOUT,
        ERROR
    }

    public enum SeverityLevel {
        TRACE,
        DEBUG,
        INFO,
        WARN,
        ERROR,
        CRITICAL
    }

    @Override
    @JsonIgnore
    public String uid() {
        return AuditLog.uid(this.getTenantId(), this.getId());
    }

    @JsonIgnore
    public static String uid(String tenantId, String id) {
        return IdUtils.fromParts(tenantId, id);
    }

    @JsonIgnore
    public boolean isSecurityEvent() {
        return eventType == EventType.SECURITY_EVENT || 
               category == EventCategory.SECURITY_VIOLATION ||
               category == EventCategory.SUSPICIOUS_ACTIVITY ||
               category == EventCategory.DATA_BREACH ||
               category == EventCategory.VULNERABILITY_DETECTED;
    }

    @JsonIgnore
    public boolean isComplianceEvent() {
        return eventType == EventType.COMPLIANCE_EVENT ||
               category == EventCategory.DATA_EXPORT ||
               category == EventCategory.DATA_RETENTION ||
               category == EventCategory.AUDIT_EXPORT ||
               category == EventCategory.COMPLIANCE_CHECK;
    }

    @JsonIgnore
    public boolean isFailure() {
        return result == EventResult.FAILURE || result == EventResult.ERROR;
    }

    @JsonIgnore
    public boolean isCritical() {
        return severity == SeverityLevel.CRITICAL || severity == SeverityLevel.ERROR;
    }

    @JsonIgnore
    public boolean isSensitive() {
        return sensitive != null && sensitive;
    }

    /**
     * Create a builder for common audit log types
     */
    public static class AuditLogBuilder<C extends AuditLog, B extends AuditLogBuilder<C, B>> {
        
        public B forAuthentication(String userId, String username, String action) {
            return this.eventType(EventType.AUTHENTICATION)
                .userId(userId)
                .username(username)
                .action(action)
                .resourceType("authentication");
        }
        
        public B forResourceAccess(String resourceType, String resourceId, String action, String userId) {
            return this.eventType(EventType.RESOURCE_ACCESS)
                .resourceType(resourceType)
                .resourceId(resourceId)
                .action(action)
                .userId(userId);
        }
        
        public B forResourceModification(String resourceType, String resourceId, String action, String userId) {
            return this.eventType(EventType.RESOURCE_MODIFICATION)
                .resourceType(resourceType)
                .resourceId(resourceId)
                .action(action)
                .userId(userId);
        }
        
        public B forSecurityEvent(String action, String description) {
            return this.eventType(EventType.SECURITY_EVENT)
                .action(action)
                .description(description)
                .severity(SeverityLevel.WARN);
        }
        
        public B forSystemEvent(String action, String description) {
            return this.eventType(EventType.SYSTEM_EVENT)
                .action(action)
                .description(description);
        }
        
        public B withSuccess() {
            return this.result(EventResult.SUCCESS);
        }
        
        public B withFailure(String errorMessage) {
            return this.result(EventResult.FAILURE)
                .errorMessage(errorMessage)
                .severity(SeverityLevel.ERROR);
        }
        
        public B withDuration(long startTime) {
            return this.durationMs(System.currentTimeMillis() - startTime);
        }
        
        public B asSensitive() {
            return this.sensitive(true);
        }
        
        public B withRetention(int days) {
            return this.retentionDays(days);
        }
    }

    /**
     * Factory methods for common audit log types
     */
    public static AuditLog loginSuccess(String tenantId, String userId, String username, String ipAddress) {
        return AuditLog.builder()
            .tenantId(tenantId)
            .id(IdUtils.create())
            .forAuthentication(userId, username, "login")
            .category(EventCategory.LOGIN)
            .ipAddress(ipAddress)
            .withSuccess()
            .build();
    }

    public static AuditLog loginFailure(String tenantId, String username, String ipAddress, String errorMessage) {
        return AuditLog.builder()
            .tenantId(tenantId)
            .id(IdUtils.create())
            .forAuthentication(null, username, "login")
            .category(EventCategory.LOGIN)
            .ipAddress(ipAddress)
            .withFailure(errorMessage)
            .asSensitive()
            .build();
    }

    public static AuditLog resourceCreated(String tenantId, String resourceType, String resourceId, 
                                         String namespace, String userId, String username) {
        return AuditLog.builder()
            .tenantId(tenantId)
            .id(IdUtils.create())
            .forResourceModification(resourceType, resourceId, "create", userId)
            .category(EventCategory.CREATE)
            .namespace(namespace)
            .username(username)
            .withSuccess()
            .build();
    }

    public static AuditLog resourceDeleted(String tenantId, String resourceType, String resourceId, 
                                         String namespace, String userId, String username) {
        return AuditLog.builder()
            .tenantId(tenantId)
            .id(IdUtils.create())
            .forResourceModification(resourceType, resourceId, "delete", userId)
            .category(EventCategory.DELETE)
            .namespace(namespace)
            .username(username)
            .withSuccess()
            .severity(SeverityLevel.WARN)
            .build();
    }

    public static AuditLog securityViolation(String tenantId, String description, String userId, String ipAddress) {
        return AuditLog.builder()
            .tenantId(tenantId)
            .id(IdUtils.create())
            .forSecurityEvent("security_violation", description)
            .category(EventCategory.SECURITY_VIOLATION)
            .userId(userId)
            .ipAddress(ipAddress)
            .severity(SeverityLevel.CRITICAL)
            .asSensitive()
            .build();
    }
}
