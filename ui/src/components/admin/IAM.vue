<template>
    <TopNavBar :title="routeInfo.title" />
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <el-tabs v-model="activeTab" class="iam-tabs">
                    <!-- Users Tab -->
                    <el-tab-pane :label="$t('iam.users')" name="users">
                        <div class="card">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <h5 class="mb-0">{{ $t('iam.users') }}</h5>
                                <el-button type="primary" @click="showUserDialog = true">
                                    <Plus class="me-2" />
                                    {{ $t('iam.add_user') }}
                                </el-button>
                            </div>
                            <div class="card-body">
                                <el-table :data="users" style="width: 100%">
                                    <el-table-column prop="username" :label="$t('username')" min-width="150" />
                                    <el-table-column prop="email" :label="$t('email')" min-width="200" />
                                    <el-table-column prop="role" :label="$t('role')" width="120">
                                        <template #default="scope">
                                            <el-tag :type="getRoleType(scope.row.role)" size="small">
                                                {{ scope.row.role }}
                                            </el-tag>
                                        </template>
                                    </el-table-column>
                                    <el-table-column prop="status" :label="$t('status')" width="100">
                                        <template #default="scope">
                                            <el-tag :type="scope.row.status === 'active' ? 'success' : 'danger'" size="small">
                                                {{ $t(`iam.status.${scope.row.status}`) }}
                                            </el-tag>
                                        </template>
                                    </el-table-column>
                                    <el-table-column prop="lastLogin" :label="$t('iam.last_login')" width="150">
                                        <template #default="scope">
                                            <span v-if="scope.row.lastLogin">
                                                {{ formatDate(scope.row.lastLogin) }}
                                            </span>
                                            <span v-else class="text-muted">{{ $t('never') }}</span>
                                        </template>
                                    </el-table-column>
                                    <el-table-column :label="$t('actions')" width="120">
                                        <template #default="scope">
                                            <el-dropdown @command="handleUserAction">
                                                <el-button size="small" text>
                                                    <DotsVertical />
                                                </el-button>
                                                <template #dropdown>
                                                    <el-dropdown-menu>
                                                        <el-dropdown-item :command="{action: 'edit', user: scope.row}">
                                                            {{ $t('edit') }}
                                                        </el-dropdown-item>
                                                        <el-dropdown-item :command="{action: 'permissions', user: scope.row}">
                                                            {{ $t('iam.permissions') }}
                                                        </el-dropdown-item>
                                                        <el-dropdown-item :command="{action: 'disable', user: scope.row}" v-if="scope.row.status === 'active'">
                                                            {{ $t('iam.disable') }}
                                                        </el-dropdown-item>
                                                        <el-dropdown-item :command="{action: 'enable', user: scope.row}" v-else>
                                                            {{ $t('iam.enable') }}
                                                        </el-dropdown-item>
                                                        <el-dropdown-item :command="{action: 'delete', user: scope.row}" divided>
                                                            {{ $t('delete') }}
                                                        </el-dropdown-item>
                                                    </el-dropdown-menu>
                                                </template>
                                            </el-dropdown>
                                        </template>
                                    </el-table-column>
                                </el-table>
                            </div>
                        </div>
                    </el-tab-pane>

                    <!-- Roles Tab -->
                    <el-tab-pane :label="$t('iam.roles')" name="roles">
                        <div class="card">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <h5 class="mb-0">{{ $t('iam.roles') }}</h5>
                                <el-button type="primary" @click="showRoleDialog = true">
                                    <Plus class="me-2" />
                                    {{ $t('iam.add_role') }}
                                </el-button>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div v-for="role in roles" :key="role.id" class="col-md-6 col-lg-4 mb-4">
                                        <div class="card h-100">
                                            <div class="card-body">
                                                <div class="d-flex justify-content-between align-items-start mb-3">
                                                    <h6 class="card-title">{{ role.name }}</h6>
                                                    <el-dropdown @command="handleRoleAction">
                                                        <el-button size="small" text>
                                                            <DotsVertical />
                                                        </el-button>
                                                        <template #dropdown>
                                                            <el-dropdown-menu>
                                                                <el-dropdown-item :command="{action: 'edit', role}">
                                                                    {{ $t('edit') }}
                                                                </el-dropdown-item>
                                                                <el-dropdown-item :command="{action: 'delete', role}" divided>
                                                                    {{ $t('delete') }}
                                                                </el-dropdown-item>
                                                            </el-dropdown-menu>
                                                        </template>
                                                    </el-dropdown>
                                                </div>
                                                <p class="card-text text-muted small">{{ role.description }}</p>
                                                <div class="mb-3">
                                                    <small class="text-muted">{{ $t('iam.permissions') }}:</small>
                                                    <div class="mt-1">
                                                        <el-tag v-for="permission in role.permissions.slice(0, 3)" :key="permission" size="small" class="me-1 mb-1">
                                                            {{ permission }}
                                                        </el-tag>
                                                        <el-tag v-if="role.permissions.length > 3" size="small" type="info">
                                                            +{{ role.permissions.length - 3 }} more
                                                        </el-tag>
                                                    </div>
                                                </div>
                                                <small class="text-muted">
                                                    {{ role.userCount }} {{ $t('iam.users_assigned') }}
                                                </small>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </el-tab-pane>

                    <!-- SSO Tab -->
                    <el-tab-pane :label="$t('iam.sso')" name="sso">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">{{ $t('iam.sso_configuration') }}</h5>
                            </div>
                            <div class="card-body">
                                <el-form :model="ssoConfig" label-width="150px">
                                    <el-form-item :label="$t('iam.sso_enabled')">
                                        <el-switch v-model="ssoConfig.enabled" />
                                    </el-form-item>
                                    <el-form-item :label="$t('iam.provider')" v-if="ssoConfig.enabled">
                                        <el-select v-model="ssoConfig.provider" :placeholder="$t('iam.select_provider')">
                                            <el-option label="SAML 2.0" value="saml" />
                                            <el-option label="OAuth 2.0" value="oauth" />
                                            <el-option label="OpenID Connect" value="oidc" />
                                            <el-option label="LDAP" value="ldap" />
                                        </el-select>
                                    </el-form-item>
                                    <el-form-item :label="$t('iam.issuer_url')" v-if="ssoConfig.enabled">
                                        <el-input v-model="ssoConfig.issuerUrl" :placeholder="$t('iam.issuer_url_placeholder')" />
                                    </el-form-item>
                                    <el-form-item :label="$t('iam.client_id')" v-if="ssoConfig.enabled">
                                        <el-input v-model="ssoConfig.clientId" :placeholder="$t('iam.client_id_placeholder')" />
                                    </el-form-item>
                                    <el-form-item :label="$t('iam.client_secret')" v-if="ssoConfig.enabled">
                                        <el-input v-model="ssoConfig.clientSecret" type="password" :placeholder="$t('iam.client_secret_placeholder')" />
                                    </el-form-item>
                                    <el-form-item>
                                        <el-button type="primary" @click="saveSSOConfig">
                                            {{ $t('save') }}
                                        </el-button>
                                        <el-button @click="testSSOConnection" v-if="ssoConfig.enabled">
                                            {{ $t('iam.test_connection') }}
                                        </el-button>
                                    </el-form-item>
                                </el-form>
                            </div>
                        </div>
                    </el-tab-pane>
                </el-tabs>
            </div>
        </div>
    </div>

    <!-- User Dialog -->
    <el-dialog v-model="showUserDialog" :title="editingUser ? $t('iam.edit_user') : $t('iam.add_user')" width="600px">
        <el-form :model="userForm" label-width="120px">
            <el-form-item :label="$t('username')" required>
                <el-input v-model="userForm.username" :placeholder="$t('iam.username_placeholder')" />
            </el-form-item>
            <el-form-item :label="$t('email')" required>
                <el-input v-model="userForm.email" type="email" :placeholder="$t('iam.email_placeholder')" />
            </el-form-item>
            <el-form-item :label="$t('role')" required>
                <el-select v-model="userForm.role" :placeholder="$t('iam.select_role')">
                    <el-option v-for="role in roles" :key="role.id" :label="role.name" :value="role.name" />
                </el-select>
            </el-form-item>
            <el-form-item :label="$t('password')" v-if="!editingUser" required>
                <el-input v-model="userForm.password" type="password" :placeholder="$t('iam.password_placeholder')" />
            </el-form-item>
        </el-form>
        <template #footer>
            <el-button @click="showUserDialog = false">{{ $t('cancel') }}</el-button>
            <el-button type="primary" @click="saveUser">
                {{ editingUser ? $t('update') : $t('create') }}
            </el-button>
        </template>
    </el-dialog>

    <!-- Role Dialog -->
    <el-dialog v-model="showRoleDialog" :title="editingRole ? $t('iam.edit_role') : $t('iam.add_role')" width="700px">
        <el-form :model="roleForm" label-width="120px">
            <el-form-item :label="$t('name')" required>
                <el-input v-model="roleForm.name" :placeholder="$t('iam.role_name_placeholder')" />
            </el-form-item>
            <el-form-item :label="$t('description')">
                <el-input v-model="roleForm.description" type="textarea" :rows="2" :placeholder="$t('iam.role_description_placeholder')" />
            </el-form-item>
            <el-form-item :label="$t('iam.permissions')" required>
                <el-checkbox-group v-model="roleForm.permissions">
                    <div class="row">
                        <div v-for="permission in availablePermissions" :key="permission" class="col-md-6 mb-2">
                            <el-checkbox :label="permission">{{ permission }}</el-checkbox>
                        </div>
                    </div>
                </el-checkbox-group>
            </el-form-item>
        </el-form>
        <template #footer>
            <el-button @click="showRoleDialog = false">{{ $t('cancel') }}</el-button>
            <el-button type="primary" @click="saveRole">
                {{ editingRole ? $t('update') : $t('create') }}
            </el-button>
        </template>
    </el-dialog>
</template>

<script setup lang="ts">
    import {ref, onMounted} from "vue";
    import {useI18n} from "vue-i18n";
    import {ElMessage, ElMessageBox} from "element-plus";
    import TopNavBar from "../layout/TopNavBar.vue";
    import Plus from "vue-material-design-icons/Plus.vue";
    import DotsVertical from "vue-material-design-icons/DotsVertical.vue";
    import useRouteContext from "../../mixins/useRouteContext";

    const {t} = useI18n();

    const routeInfo = ref({
        title: t("iam"),
    });

    useRouteContext(routeInfo);

    // Reactive data
    const activeTab = ref('users');
    const showUserDialog = ref(false);
    const showRoleDialog = ref(false);
    const editingUser = ref(null);
    const editingRole = ref(null);

    const users = ref([
        {
            id: 1,
            username: 'admin',
            email: 'admin@kestra.io',
            role: 'Administrator',
            status: 'active',
            lastLogin: new Date('2024-01-15T10:30:00')
        },
        {
            id: 2,
            username: 'developer',
            email: 'dev@kestra.io',
            role: 'Developer',
            status: 'active',
            lastLogin: new Date('2024-01-14T15:45:00')
        },
        {
            id: 3,
            username: 'viewer',
            email: 'viewer@kestra.io',
            role: 'Viewer',
            status: 'inactive',
            lastLogin: null
        }
    ]);

    const roles = ref([
        {
            id: 1,
            name: 'Administrator',
            description: 'Full system access with all permissions',
            permissions: ['flows.read', 'flows.write', 'flows.delete', 'executions.read', 'executions.write', 'admin.users', 'admin.system'],
            userCount: 1
        },
        {
            id: 2,
            name: 'Developer',
            description: 'Can create and manage flows and executions',
            permissions: ['flows.read', 'flows.write', 'executions.read', 'executions.write', 'templates.read'],
            userCount: 1
        },
        {
            id: 3,
            name: 'Viewer',
            description: 'Read-only access to flows and executions',
            permissions: ['flows.read', 'executions.read'],
            userCount: 1
        }
    ]);

    const availablePermissions = ref([
        'flows.read', 'flows.write', 'flows.delete',
        'executions.read', 'executions.write', 'executions.delete',
        'templates.read', 'templates.write', 'templates.delete',
        'secrets.read', 'secrets.write', 'secrets.delete',
        'namespaces.read', 'namespaces.write', 'namespaces.delete',
        'admin.users', 'admin.roles', 'admin.system', 'admin.audit'
    ]);

    const ssoConfig = ref({
        enabled: false,
        provider: '',
        issuerUrl: '',
        clientId: '',
        clientSecret: ''
    });

    const userForm = ref({
        username: '',
        email: '',
        role: '',
        password: ''
    });

    const roleForm = ref({
        name: '',
        description: '',
        permissions: []
    });

    // Methods
    function getRoleType(role: string) {
        switch (role) {
            case 'Administrator': return 'danger';
            case 'Developer': return 'primary';
            case 'Viewer': return 'info';
            default: return '';
        }
    }

    function formatDate(date: Date) {
        return new Intl.DateTimeFormat('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        }).format(date);
    }

    function handleUserAction(command: any) {
        if (command.action === 'edit') {
            editUser(command.user);
        } else if (command.action === 'delete') {
            deleteUser(command.user);
        } else if (command.action === 'disable') {
            toggleUserStatus(command.user, 'inactive');
        } else if (command.action === 'enable') {
            toggleUserStatus(command.user, 'active');
        } else if (command.action === 'permissions') {
            ElMessage.info(`Managing permissions for: ${command.user.username}`);
        }
    }

    function handleRoleAction(command: any) {
        if (command.action === 'edit') {
            editRole(command.role);
        } else if (command.action === 'delete') {
            deleteRole(command.role);
        }
    }

    function editUser(user: any) {
        editingUser.value = user;
        userForm.value = { ...user, password: '' };
        showUserDialog.value = true;
    }

    function editRole(role: any) {
        editingRole.value = role;
        roleForm.value = { ...role };
        showRoleDialog.value = true;
    }

    function toggleUserStatus(user: any, status: string) {
        user.status = status;
        ElMessage.success(t(`iam.user_${status}_success`));
    }

    async function deleteUser(user: any) {
        try {
            await ElMessageBox.confirm(
                t('iam.delete_user_confirm', { username: user.username }),
                t('confirm'),
                {
                    confirmButtonText: t('delete'),
                    cancelButtonText: t('cancel'),
                    type: 'warning',
                }
            );
            
            const index = users.value.findIndex(u => u.id === user.id);
            if (index > -1) {
                users.value.splice(index, 1);
                ElMessage.success(t('iam.user_deleted_success'));
            }
        } catch {
            // User cancelled
        }
    }

    async function deleteRole(role: any) {
        try {
            await ElMessageBox.confirm(
                t('iam.delete_role_confirm', { name: role.name }),
                t('confirm'),
                {
                    confirmButtonText: t('delete'),
                    cancelButtonText: t('cancel'),
                    type: 'warning',
                }
            );
            
            const index = roles.value.findIndex(r => r.id === role.id);
            if (index > -1) {
                roles.value.splice(index, 1);
                ElMessage.success(t('iam.role_deleted_success'));
            }
        } catch {
            // User cancelled
        }
    }

    function saveUser() {
        if (!userForm.value.username.trim() || !userForm.value.email.trim()) {
            ElMessage.error(t('iam.user_fields_required'));
            return;
        }

        if (editingUser.value) {
            // Update existing user
            const index = users.value.findIndex(u => u.id === editingUser.value.id);
            if (index > -1) {
                users.value[index] = { 
                    ...users.value[index], 
                    ...userForm.value
                };
                ElMessage.success(t('iam.user_updated_success'));
            }
        } else {
            // Create new user
            const newUser = {
                id: Date.now(),
                ...userForm.value,
                status: 'active',
                lastLogin: null
            };
            users.value.push(newUser);
            ElMessage.success(t('iam.user_created_success'));
        }

        showUserDialog.value = false;
        editingUser.value = null;
        userForm.value = {
            username: '',
            email: '',
            role: '',
            password: ''
        };
    }

    function saveRole() {
        if (!roleForm.value.name.trim() || roleForm.value.permissions.length === 0) {
            ElMessage.error(t('iam.role_fields_required'));
            return;
        }

        if (editingRole.value) {
            // Update existing role
            const index = roles.value.findIndex(r => r.id === editingRole.value.id);
            if (index > -1) {
                roles.value[index] = { 
                    ...roles.value[index], 
                    ...roleForm.value
                };
                ElMessage.success(t('iam.role_updated_success'));
            }
        } else {
            // Create new role
            const newRole = {
                id: Date.now(),
                ...roleForm.value,
                userCount: 0
            };
            roles.value.push(newRole);
            ElMessage.success(t('iam.role_created_success'));
        }

        showRoleDialog.value = false;
        editingRole.value = null;
        roleForm.value = {
            name: '',
            description: '',
            permissions: []
        };
    }

    function saveSSOConfig() {
        ElMessage.success(t('iam.sso_config_saved'));
    }

    function testSSOConnection() {
        ElMessage.info(t('iam.testing_sso_connection'));
        // Simulate connection test
        setTimeout(() => {
            ElMessage.success(t('iam.sso_connection_success'));
        }, 2000);
    }

    onMounted(() => {
        // TODO: Load data from API
    });
</script>

<style lang="scss" scoped>
    .card {
        border: 1px solid var(--ks-border-primary);
        border-radius: 8px;
        
        .card-header {
            background-color: var(--ks-background-secondary);
            border-bottom: 1px solid var(--ks-border-primary);
        }
    }

    .iam-tabs {
        :deep(.el-tabs__header) {
            margin-bottom: 20px;
        }
    }
</style>
