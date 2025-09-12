package io.kestra.core.repositories;

import io.kestra.core.models.QueryFilter;
import io.kestra.core.models.apps.App;
import io.micronaut.data.model.Pageable;
import jakarta.annotation.Nullable;
import jakarta.validation.ConstraintViolationException;

import java.util.List;
import java.util.Optional;

public interface AppRepositoryInterface {

    Optional<App> findById(String tenantId, String namespace, String id);

    Optional<App> findByIdWithoutAcl(String tenantId, String namespace, String id);

    List<App> findAll(String tenantId);

    List<App> findByNamespace(String tenantId, String namespace);

    List<App> findByNamespacePrefix(String tenantId, String namespacePrefix);

    ArrayListTotal<App> find(
        Pageable pageable,
        @Nullable String tenantId,
        @Nullable List<QueryFilter> filters
    );

    ArrayListTotal<App> findByStatus(
        Pageable pageable,
        @Nullable String tenantId,
        @Nullable String namespace,
        @Nullable App.AppStatus status
    );

    ArrayListTotal<App> findByType(
        Pageable pageable,
        @Nullable String tenantId,
        @Nullable String namespace,
        @Nullable App.AppType type
    );

    ArrayListTotal<App> findByOwner(
        Pageable pageable,
        @Nullable String tenantId,
        @Nullable String owner
    );

    ArrayListTotal<App> findByTags(
        Pageable pageable,
        @Nullable String tenantId,
        @Nullable String namespace,
        @Nullable List<String> tags
    );

    List<String> findDistinctNamespace(String tenantId);

    List<String> findDistinctOwners(String tenantId);

    List<String> findDistinctTags(String tenantId, @Nullable String namespace);

    List<App.AppType> findDistinctTypes(String tenantId, @Nullable String namespace);

    List<App.AppStatus> findDistinctStatuses(String tenantId, @Nullable String namespace);

    /**
     * Counts the total number of apps.
     *
     * @param tenantId the tenant ID.
     * @return The count.
     */
    int count(@Nullable String tenantId);

    /**
     * Counts apps by status.
     *
     * @param tenantId the tenant ID.
     * @param status the app status.
     * @return The count.
     */
    int countByStatus(@Nullable String tenantId, @Nullable App.AppStatus status);

    /**
     * Counts apps by type.
     *
     * @param tenantId the tenant ID.
     * @param type the app type.
     * @return The count.
     */
    int countByType(@Nullable String tenantId, @Nullable App.AppType type);

    /**
     * Find apps associated with a specific flow.
     *
     * @param tenantId the tenant ID.
     * @param flowId the flow ID.
     * @return List of apps.
     */
    List<App> findByFlowId(String tenantId, String flowId);

    /**
     * Find apps by deployment status.
     *
     * @param tenantId the tenant ID.
     * @param deploymentStatus the deployment status.
     * @return List of apps.
     */
    List<App> findByDeploymentStatus(String tenantId, App.AppDeployment.DeploymentStatus deploymentStatus);

    /**
     * Find apps that need attention (failed deployments, errors, etc.).
     *
     * @param tenantId the tenant ID.
     * @return List of apps requiring attention.
     */
    List<App> findRequiringAttention(String tenantId);

    /**
     * Search apps by text query.
     *
     * @param pageable pagination parameters.
     * @param tenantId the tenant ID.
     * @param query search query.
     * @param namespace optional namespace filter.
     * @return Paginated search results.
     */
    ArrayListTotal<App> search(
        Pageable pageable,
        @Nullable String tenantId,
        @Nullable String query,
        @Nullable String namespace
    );

    App create(App app) throws ConstraintViolationException;

    App update(App app, App previous) throws ConstraintViolationException;

    App delete(App app);

    /**
     * Update app status.
     *
     * @param tenantId the tenant ID.
     * @param namespace the namespace.
     * @param id the app ID.
     * @param status the new status.
     * @return Updated app.
     */
    Optional<App> updateStatus(String tenantId, String namespace, String id, App.AppStatus status);

    /**
     * Update app deployment.
     *
     * @param tenantId the tenant ID.
     * @param namespace the namespace.
     * @param id the app ID.
     * @param deployment the deployment configuration.
     * @return Updated app.
     */
    Optional<App> updateDeployment(String tenantId, String namespace, String id, App.AppDeployment deployment);

    /**
     * Increment app usage statistics.
     *
     * @param tenantId the tenant ID.
     * @param namespace the namespace.
     * @param id the app ID.
     */
    void incrementUsage(String tenantId, String namespace, String id);

    /**
     * Bulk operations for apps.
     */
    List<App> saveAll(List<App> apps);

    void deleteAll(List<App> apps);

    /**
     * Get app statistics.
     *
     * @param tenantId the tenant ID.
     * @param namespace optional namespace filter.
     * @return App statistics.
     */
    AppStatistics getStatistics(String tenantId, @Nullable String namespace);

    /**
     * App statistics data class.
     */
    class AppStatistics {
        private final long totalApps;
        private final long activeApps;
        private final long deployedApps;
        private final long failedApps;
        private final java.util.Map<App.AppType, Long> appsByType;
        private final java.util.Map<App.AppStatus, Long> appsByStatus;

        public AppStatistics(long totalApps, long activeApps, long deployedApps, long failedApps,
                           java.util.Map<App.AppType, Long> appsByType,
                           java.util.Map<App.AppStatus, Long> appsByStatus) {
            this.totalApps = totalApps;
            this.activeApps = activeApps;
            this.deployedApps = deployedApps;
            this.failedApps = failedApps;
            this.appsByType = appsByType;
            this.appsByStatus = appsByStatus;
        }

        public long getTotalApps() { return totalApps; }
        public long getActiveApps() { return activeApps; }
        public long getDeployedApps() { return deployedApps; }
        public long getFailedApps() { return failedApps; }
        public java.util.Map<App.AppType, Long> getAppsByType() { return appsByType; }
        public java.util.Map<App.AppStatus, Long> getAppsByStatus() { return appsByStatus; }
    }
}
