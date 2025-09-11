import {FilterLanguage, FilterKeyCompletions} from "./filterLanguage";

export class AppFilterLanguage extends FilterLanguage {
    constructor() {
        const filterKeyCompletions: Record<string, FilterKeyCompletions> = {
            "name": {
                type: "string",
                description: "Filter by app name"
            },
            "namespace": {
                type: "string", 
                description: "Filter by namespace"
            },
            "type": {
                type: "enum",
                description: "Filter by app type",
                values: ["form", "dashboard", "workflow-trigger", "custom"]
            },
            "status": {
                type: "enum",
                description: "Filter by app status",
                values: ["active", "inactive", "draft"]
            },
            "labels": {
                type: "string",
                description: "Filter by labels (key:value format)"
            },
            "createdBy": {
                type: "string",
                description: "Filter by creator"
            },
            "updatedBy": {
                type: "string", 
                description: "Filter by last updater"
            },
            "createdAt": {
                type: "date",
                description: "Filter by creation date"
            },
            "updatedAt": {
                type: "date",
                description: "Filter by last update date"
            },
            "lastExecutionDate": {
                type: "date",
                description: "Filter by last execution date"
            },
            "executionCount": {
                type: "number",
                description: "Filter by execution count"
            },
            "description": {
                type: "string",
                description: "Filter by app description"
            }
        };

        super("apps", filterKeyCompletions, true);
    }
}

export const AppFilterLanguage = new AppFilterLanguage();
