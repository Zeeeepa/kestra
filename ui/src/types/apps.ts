// Apps Type Definitions for Kestra Enterprise Features

export type AppState = "OPEN" | "CREATED" | "RUNNING" | "PAUSE" | "RESUME" | "SUCCESS" | "FAILURE" | "ERROR" | "FALLBACK";

export type ButtonStyle = "DEFAULT" | "SUCCESS" | "DANGER" | "INFO";
export type ButtonSize = "SMALL" | "MEDIUM" | "LARGE";
export type AlertStyle = "SUCCESS" | "WARNING" | "ERROR" | "INFO";
export type LogLevel = "TRACE" | "DEBUG" | "INFO" | "WARN" | "ERROR";

export interface BaseBlockProps {
    type: string;
    states?: AppState[];
    id?: string;
    className?: string;
}

// Layout Block Interfaces
export interface MarkdownBlockProps extends BaseBlockProps {
    type: "io.kestra.plugin.ee.apps.core.blocks.Markdown";
    content: string;
}

export interface RedirectToBlockProps extends BaseBlockProps {
    type: "io.kestra.plugin.ee.apps.blocks.RedirectTo";
    url: string;
    delay?: string; // ISO 8601 duration format (e.g., "PT60S")
}

export interface CreateExecutionFormBlockProps extends BaseBlockProps {
    type: "io.kestra.plugin.ee.apps.execution.blocks.CreateExecutionForm";
}

export interface ResumeExecutionFormBlockProps extends BaseBlockProps {
    type: "io.kestra.plugin.ee.apps.execution.blocks.ResumeExecutionForm";
}

export interface CreateExecutionButtonBlockProps extends BaseBlockProps {
    type: "io.kestra.plugin.ee.apps.execution.blocks.CreateExecutionButton";
    text?: string;
    style?: ButtonStyle;
    size?: ButtonSize;
}

export interface CancelExecutionButtonBlockProps extends BaseBlockProps {
    type: "io.kestra.plugin.ee.apps.execution.blocks.CancelExecutionButton";
    text?: string;
    style?: ButtonStyle;
    size?: ButtonSize;
}

export interface ResumeExecutionButtonBlockProps extends BaseBlockProps {
    type: "io.kestra.plugin.ee.apps.execution.blocks.ResumeExecutionButton";
    text?: string;
    style?: ButtonStyle;
    size?: ButtonSize;
}

export interface ExecutionInputsBlockProps extends BaseBlockProps {
    type: "io.kestra.plugin.ee.apps.execution.blocks.Inputs";
    filter?: {
        include?: string[];
        exclude?: string[];
    };
}

export interface ExecutionOutputsBlockProps extends BaseBlockProps {
    type: "io.kestra.plugin.ee.apps.execution.blocks.Outputs";
    filter?: {
        include?: string[];
        exclude?: string[];
    };
}

export interface ExecutionLogsBlockProps extends BaseBlockProps {
    type: "io.kestra.plugin.ee.apps.execution.blocks.Logs";
    filter?: {
        logLevel?: LogLevel;
        taskIds?: string[];
    };
}

export interface LoadingBlockProps extends BaseBlockProps {
    type: "io.kestra.plugin.ee.apps.core.blocks.Loading";
}

export interface AlertBlockProps extends BaseBlockProps {
    type: "io.kestra.plugin.ee.apps.core.blocks.Alert";
    style: AlertStyle;
    showIcon?: boolean;
    content: string;
}

export interface ButtonBlockProps extends BaseBlockProps {
    type: "io.kestra.plugin.ee.apps.core.blocks.Button";
    text: string;
    url: string;
    style?: ButtonStyle;
}

export interface TaskOutputsBlockProps extends BaseBlockProps {
    type: "io.kestra.plugin.ee.apps.execution.blocks.TaskOutputs";
    outputs: TaskOutput[];
}

export interface TaskOutput {
    displayName: string;
    value: string;
    type: "FILE" | "TEXT" | "JSON" | "HTML";
}

// Union type for all block props
export type LayoutBlockProps = 
    | MarkdownBlockProps
    | RedirectToBlockProps
    | CreateExecutionFormBlockProps
    | ResumeExecutionFormBlockProps
    | CreateExecutionButtonBlockProps
    | CancelExecutionButtonBlockProps
    | ResumeExecutionButtonBlockProps
    | ExecutionInputsBlockProps
    | ExecutionOutputsBlockProps
    | ExecutionLogsBlockProps
    | LoadingBlockProps
    | AlertBlockProps
    | ButtonBlockProps
    | TaskOutputsBlockProps;

// App Configuration
export interface AppLayout {
    blocks: LayoutBlockProps[];
}

export interface AppConfig {
    id: string;
    namespace: string;
    name: string;
    description?: string;
    type: "FORM" | "APPROVAL";
    access: "PUBLIC" | "PRIVATE";
    tags?: string[];
    layout: Record<AppState, AppLayout>;
    flowId?: string;
    flowRevision?: number;
    enabled: boolean;
    createdAt: Date;
    updatedAt: Date;
    createdBy?: string;
    updatedBy?: string;
}

// App Execution Context
export interface AppExecutionContext {
    appId: string;
    executionId?: string;
    state: AppState;
    inputs?: Record<string, any>;
    outputs?: Record<string, any>;
    logs?: LogEntry[];
    error?: string;
    startDate?: Date;
    endDate?: Date;
}

export interface LogEntry {
    timestamp: Date;
    level: LogLevel;
    message: string;
    taskId?: string;
    thread?: string;
}

// Block Registry
export interface BlockDefinition {
    type: string;
    component: any; // Vue component
    name: string;
    description: string;
    category: "core" | "execution" | "ui";
    availableStates: AppState[];
    defaultProps: Partial<LayoutBlockProps>;
}

// App Permissions
export interface AppPermissions {
    canExecute: boolean;
    canManage: boolean;
    canView: boolean;
    canShare: boolean;
}

// App Analytics
export interface AppAnalytics {
    totalExecutions: number;
    successfulExecutions: number;
    failedExecutions: number;
    averageExecutionTime: number;
    lastExecutionDate?: Date;
    executionTrends: ExecutionTrend[];
}

export interface ExecutionTrend {
    date: Date;
    executions: number;
    successRate: number;
    averageTime: number;
}

// Form Validation
export interface FormValidation {
    field: string;
    rules: ValidationRule[];
}

export interface ValidationRule {
    type: "required" | "minLength" | "maxLength" | "pattern" | "custom";
    value?: any;
    message: string;
}

// App URL Configuration
export interface AppUrlConfig {
    appId: string;
    publicUrl: string;
    shareableUrl: string;
    embedUrl: string;
    expiresAt?: Date;
    accessCount: number;
    lastAccessDate?: Date;
}
