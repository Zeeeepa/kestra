package io.kestra.core.models.instance;

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
import java.util.List;
import java.util.Map;

@SuperBuilder(toBuilder = true)
@Getter
@AllArgsConstructor
@NoArgsConstructor
@Introspected
@ToString
@EqualsAndHashCode
@Schema(description = "Instance metrics for enterprise system monitoring")
public class InstanceMetrics implements TenantInterface, HasUID {
    
    @Setter
    @Pattern(regexp = "^[a-z0-9][a-z0-9_-]*")
    @Schema(description = "The tenant identifier", hidden = true)
    private String tenantId;

    @NotNull
    @NotBlank
    @Schema(description = "The metrics unique identifier")
    private String id;

    @NotNull
    @Schema(description = "The instance identifier")
    private String instanceId;

    @NotNull
    @Schema(description = "The instance type")
    private InstanceType instanceType;

    @NotNull
    @Schema(description = "The instance status")
    private InstanceStatus status;

    @NotNull
    @Schema(description = "The timestamp when metrics were collected")
    @Builder.Default
    private Instant timestamp = Instant.now();

    @Schema(description = "Instance hostname")
    private String hostname;

    @Schema(description = "Instance IP address")
    private String ipAddress;

    @Schema(description = "Instance port")
    private Integer port;

    @Schema(description = "Instance version")
    private String version;

    @Schema(description = "Instance uptime in seconds")
    private Long uptimeSeconds;

    @Schema(description = "Instance start time")
    private Instant startTime;

    @Valid
    @Schema(description = "System resource metrics")
    private SystemMetrics systemMetrics;

    @Valid
    @Schema(description = "Application-specific metrics")
    private ApplicationMetrics applicationMetrics;

    @Valid
    @Schema(description = "Performance metrics")
    private PerformanceMetrics performanceMetrics;

    @Valid
    @Schema(description = "Health check results")
    private HealthCheck healthCheck;

    @Valid
    @Schema(description = "Additional custom metrics")
    private Map<String, Object> customMetrics;

    @Schema(description = "Instance tags")
    private List<String> tags;

    @Schema(description = "Instance environment")
    private String environment;

    @Schema(description = "Instance region")
    private String region;

    @Schema(description = "Instance availability zone")
    private String availabilityZone;

    public enum InstanceType {
        WEBSERVER,
        EXECUTOR,
        SCHEDULER,
        WORKER,
        INDEXER,
        STANDALONE,
        CUSTOM
    }

    public enum InstanceStatus {
        STARTING,
        HEALTHY,
        DEGRADED,
        UNHEALTHY,
        STOPPING,
        STOPPED,
        ERROR,
        UNKNOWN
    }

    @SuperBuilder(toBuilder = true)
    @Getter
    @AllArgsConstructor
    @NoArgsConstructor
    @Introspected
    @ToString
    @EqualsAndHashCode
    public static class SystemMetrics {
        @Schema(description = "CPU usage percentage (0-100)")
        private Double cpuUsagePercent;

        @Schema(description = "Memory usage in bytes")
        private Long memoryUsedBytes;

        @Schema(description = "Total memory in bytes")
        private Long memoryTotalBytes;

        @Schema(description = "Memory usage percentage (0-100)")
        private Double memoryUsagePercent;

        @Schema(description = "Disk usage in bytes")
        private Long diskUsedBytes;

        @Schema(description = "Total disk space in bytes")
        private Long diskTotalBytes;

        @Schema(description = "Disk usage percentage (0-100)")
        private Double diskUsagePercent;

        @Schema(description = "Network bytes received")
        private Long networkBytesReceived;

        @Schema(description = "Network bytes sent")
        private Long networkBytesSent;

        @Schema(description = "Number of CPU cores")
        private Integer cpuCores;

        @Schema(description = "System load average (1 minute)")
        private Double loadAverage1m;

        @Schema(description = "System load average (5 minutes)")
        private Double loadAverage5m;

        @Schema(description = "System load average (15 minutes)")
        private Double loadAverage15m;

        @Schema(description = "Number of open file descriptors")
        private Integer openFileDescriptors;

        @Schema(description = "Maximum file descriptors")
        private Integer maxFileDescriptors;

        @JsonIgnore
        public boolean isMemoryHigh() {
            return memoryUsagePercent != null && memoryUsagePercent > 80.0;
        }

        @JsonIgnore
        public boolean isCpuHigh() {
            return cpuUsagePercent != null && cpuUsagePercent > 80.0;
        }

        @JsonIgnore
        public boolean isDiskHigh() {
            return diskUsagePercent != null && diskUsagePercent > 85.0;
        }
    }

    @SuperBuilder(toBuilder = true)
    @Getter
    @AllArgsConstructor
    @NoArgsConstructor
    @Introspected
    @ToString
    @EqualsAndHashCode
    public static class ApplicationMetrics {
        @Schema(description = "JVM heap memory used in bytes")
        private Long jvmHeapUsed;

        @Schema(description = "JVM heap memory max in bytes")
        private Long jvmHeapMax;

        @Schema(description = "JVM non-heap memory used in bytes")
        private Long jvmNonHeapUsed;

        @Schema(description = "JVM non-heap memory max in bytes")
        private Long jvmNonHeapMax;

        @Schema(description = "Number of active threads")
        private Integer activeThreads;

        @Schema(description = "Number of daemon threads")
        private Integer daemonThreads;

        @Schema(description = "Peak thread count")
        private Integer peakThreads;

        @Schema(description = "Total started thread count")
        private Long totalStartedThreads;

        @Schema(description = "Garbage collection count")
        private Long gcCollections;

        @Schema(description = "Garbage collection time in milliseconds")
        private Long gcTimeMs;

        @Schema(description = "Number of loaded classes")
        private Integer loadedClasses;

        @Schema(description = "Total loaded classes")
        private Long totalLoadedClasses;

        @Schema(description = "Unloaded classes")
        private Long unloadedClasses;

        @Schema(description = "Application-specific counters")
        private Map<String, Long> counters;

        @Schema(description = "Application-specific gauges")
        private Map<String, Double> gauges;

        @JsonIgnore
        public double getJvmHeapUsagePercent() {
            if (jvmHeapUsed == null || jvmHeapMax == null || jvmHeapMax == 0) {
                return 0.0;
            }
            return (double) jvmHeapUsed / jvmHeapMax * 100.0;
        }

        @JsonIgnore
        public boolean isJvmHeapHigh() {
            return getJvmHeapUsagePercent() > 80.0;
        }
    }

    @SuperBuilder(toBuilder = true)
    @Getter
    @AllArgsConstructor
    @NoArgsConstructor
    @Introspected
    @ToString
    @EqualsAndHashCode
    public static class PerformanceMetrics {
        @Schema(description = "Average response time in milliseconds")
        private Double avgResponseTimeMs;

        @Schema(description = "95th percentile response time in milliseconds")
        private Double p95ResponseTimeMs;

        @Schema(description = "99th percentile response time in milliseconds")
        private Double p99ResponseTimeMs;

        @Schema(description = "Requests per second")
        private Double requestsPerSecond;

        @Schema(description = "Error rate percentage")
        private Double errorRatePercent;

        @Schema(description = "Total requests processed")
        private Long totalRequests;

        @Schema(description = "Total errors")
        private Long totalErrors;

        @Schema(description = "Active connections")
        private Integer activeConnections;

        @Schema(description = "Queue size")
        private Integer queueSize;

        @Schema(description = "Queue capacity")
        private Integer queueCapacity;

        @Schema(description = "Throughput metrics")
        private Map<String, Double> throughput;

        @Schema(description = "Latency metrics")
        private Map<String, Double> latency;

        @JsonIgnore
        public boolean isPerformanceDegraded() {
            return (errorRatePercent != null && errorRatePercent > 5.0) ||
                   (p95ResponseTimeMs != null && p95ResponseTimeMs > 1000.0);
        }

        @JsonIgnore
        public double getQueueUsagePercent() {
            if (queueSize == null || queueCapacity == null || queueCapacity == 0) {
                return 0.0;
            }
            return (double) queueSize / queueCapacity * 100.0;
        }
    }

    @SuperBuilder(toBuilder = true)
    @Getter
    @AllArgsConstructor
    @NoArgsConstructor
    @Introspected
    @ToString
    @EqualsAndHashCode
    public static class HealthCheck {
        @Schema(description = "Overall health status")
        private HealthStatus status;

        @Schema(description = "Health check timestamp")
        @Builder.Default
        private Instant timestamp = Instant.now();

        @Schema(description = "Health check duration in milliseconds")
        private Long durationMs;

        @Schema(description = "Individual component health checks")
        private Map<String, ComponentHealth> components;

        @Schema(description = "Health check details")
        private String details;

        @Schema(description = "Health check error message")
        private String errorMessage;

        public enum HealthStatus {
            HEALTHY,
            DEGRADED,
            UNHEALTHY,
            UNKNOWN
        }

        @SuperBuilder(toBuilder = true)
        @Getter
        @AllArgsConstructor
        @NoArgsConstructor
        @Introspected
        @ToString
        @EqualsAndHashCode
        public static class ComponentHealth {
            @Schema(description = "Component health status")
            private HealthStatus status;

            @Schema(description = "Component details")
            private String details;

            @Schema(description = "Component error message")
            private String errorMessage;

            @Schema(description = "Component response time in milliseconds")
            private Long responseTimeMs;
        }

        @JsonIgnore
        public boolean isHealthy() {
            return status == HealthStatus.HEALTHY;
        }

        @JsonIgnore
        public boolean hasUnhealthyComponents() {
            if (components == null) return false;
            return components.values().stream()
                .anyMatch(c -> c.getStatus() == HealthStatus.UNHEALTHY);
        }
    }

    @Override
    @JsonIgnore
    public String uid() {
        return InstanceMetrics.uid(this.getTenantId(), this.getId());
    }

    @JsonIgnore
    public static String uid(String tenantId, String id) {
        return IdUtils.fromParts(tenantId, id);
    }

    @JsonIgnore
    public boolean isHealthy() {
        return status == InstanceStatus.HEALTHY && 
               (healthCheck == null || healthCheck.isHealthy());
    }

    @JsonIgnore
    public boolean requiresAttention() {
        if (status == InstanceStatus.UNHEALTHY || status == InstanceStatus.ERROR) {
            return true;
        }
        
        if (systemMetrics != null && 
            (systemMetrics.isMemoryHigh() || systemMetrics.isCpuHigh() || systemMetrics.isDiskHigh())) {
            return true;
        }
        
        if (applicationMetrics != null && applicationMetrics.isJvmHeapHigh()) {
            return true;
        }
        
        if (performanceMetrics != null && performanceMetrics.isPerformanceDegraded()) {
            return true;
        }
        
        return false;
    }

    @JsonIgnore
    public String getDisplayName() {
        if (hostname != null) {
            return hostname + ":" + (port != null ? port : "");
        }
        return instanceId;
    }

    public InstanceMetrics withStatus(InstanceStatus status) {
        return this.toBuilder()
            .status(status)
            .timestamp(Instant.now())
            .build();
    }

    public InstanceMetrics withHealthCheck(HealthCheck healthCheck) {
        return this.toBuilder()
            .healthCheck(healthCheck)
            .timestamp(Instant.now())
            .build();
    }
}
