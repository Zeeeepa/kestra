import {FilterLanguage, FilterKeyCompletions} from "./filterLanguage";

export class TestFilterLanguage extends FilterLanguage {
    constructor() {
        const filterKeyCompletions: Record<string, FilterKeyCompletions> = {
            "name": {
                type: "string",
                description: "Filter by test suite name"
            },
            "namespace": {
                type: "string", 
                description: "Filter by namespace"
            },
            "flowId": {
                type: "string",
                description: "Filter by associated flow ID"
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
            "lastRunDate": {
                type: "date",
                description: "Filter by last run date"
            },
            "totalRuns": {
                type: "number",
                description: "Filter by total number of runs"
            },
            "successRate": {
                type: "number",
                description: "Filter by success rate (0.0 to 1.0)"
            },
            "testCaseCount": {
                type: "number",
                description: "Filter by number of test cases"
            },
            "description": {
                type: "string",
                description: "Filter by test suite description"
            },
            "status": {
                type: "enum",
                description: "Filter by test execution status",
                values: ["running", "passed", "failed", "cancelled", "error"]
            }
        };

        super("tests", filterKeyCompletions, true);
    }
}

export const TestFilterLanguage = new TestFilterLanguage();
