<p align="center">
  <a href="https://www.kestra.io">
    <img src="https://kestra.io/banner.png"  alt="Kestra workflow orchestrator" />
  </a>
</p>

<h1 align="center" style="border-bottom: none">
    Event-Driven Declarative Orchestration Platform
</h1>

<div align="center">
 <a href="https://github.com/kestra-io/kestra/releases"><img src="https://img.shields.io/github/tag-pre/kestra-io/kestra.svg?color=blueviolet" alt="Last Version" /></a>
  <a href="https://github.com/kestra-io/kestra/blob/develop/LICENSE"><img src="https://img.shields.io/github/license/kestra-io/kestra?color=blueviolet" alt="License" /></a>
  <a href="https://github.com/kestra-io/kestra/stargazers"><img src="https://img.shields.io/github/stars/kestra-io/kestra?color=blueviolet&logo=github" alt="Github star" /></a> <br>
<a href="https://kestra.io"><img src="https://img.shields.io/badge/Website-kestra.io-192A4E?color=blueviolet" alt="Kestra infinitely scalable orchestration and scheduling platform"></a>
<a href="https://kestra.io/slack"><img src="https://img.shields.io/badge/Slack-Join%20Community-blueviolet?logo=slack" alt="Slack"></a>
</div>

<br />

<p align="center">
    <a href="https://x.com/kestra_io"><img height="25" src="https://kestra.io/twitter.svg" alt="X(formerly Twitter)" /></a> &nbsp;
    <a href="https://www.linkedin.com/company/kestra/"><img height="25" src="https://kestra.io/linkedin.svg" alt="linkedin" /></a> &nbsp;
<a href="https://www.youtube.com/@kestra-io"><img height="25" src="https://kestra.io/youtube.svg" alt="youtube" /></a> &nbsp;
</p>

<p align="center">
  <a href="https://trendshift.io/repositories/2714" target="_blank">
    <img src="https://trendshift.io/api/badge/repositories/2714" alt="kestra-io%2Fkestra | Trendshift" width="250" height="55"/>
  </a>
  <a href="https://www.producthunt.com/posts/kestra?embed=true&utm_source=badge-top-post-badge&utm_medium=badge&utm_souce=badge-kestra" target="_blank"><img src="https://api.producthunt.com/widgets/embed-image/v1/top-post-badge.svg?post_id=612077&theme=light&period=daily&t=1740737506162" alt="Kestra - All&#0045;in&#0045;one&#0032;automation&#0032;&#0038;&#0032;orchestration&#0032;platform | Product Hunt" style="width: 250px; height: 54px;" width="250" height="54" /></a>
</p>

<p align="center">
    <a href="https://go.kestra.io/video/product-overview" target="_blank">
        <img src="https://kestra.io/startvideo.png" alt="Get started in 4 minutes with Kestra" width="640px" />
    </a>
</p>
<p align="center" style="color:grey;"><i>Click on the image to learn how to get started with Kestra in 4 minutes.</i></p>


## 🌟 What is Kestra?

Kestra is an open-source, event-driven orchestration platform that makes both **scheduled** and **event-driven** workflows easy. By bringing **Infrastructure as Code** best practices to data, process, and microservice orchestration, you can build reliable [workflows](https://kestra.io/docs/getting-started) directly from the UI in just a few lines of YAML.

**Key Features:**
- **Everything as Code and from the UI:** keep **workflows as code** with a **Git Version Control** integration, even when building them from the UI.
- **Event-Driven & Scheduled Workflows:** automate both **scheduled** and **real-time** event-driven workflows via a simple `trigger` definition.
- **Declarative YAML Interface:** define workflows using a simple configuration in the **built-in code editor**.
- **Rich Plugin Ecosystem:** hundreds of plugins built in to extract data from any database, cloud storage, or API, and **run scripts in any language**.
- **Intuitive UI & Code Editor:** build and visualize workflows directly from the UI with syntax highlighting, auto-completion and real-time syntax validation.
- **Scalable:** designed to handle millions of workflows, with high availability and fault tolerance.
- **Version Control Friendly:** write your workflows from the built-in code Editor and push them to your preferred Git branch directly from Kestra, enabling best practices with CI/CD pipelines and version control systems.
- **Structure & Resilience**: tame chaos and bring resilience to your workflows with **namespaces**, **labels**, **subflows**, **retries**, **timeout**, **error handling**, **inputs**, **outputs** that generate artifacts in the UI, **variables**, **conditional branching**, **advanced scheduling**, **event triggers**, **backfills**, **dynamic tasks**, **sequential and parallel tasks**, and skip tasks or triggers when needed by setting the flag `disabled` to `true`.


🧑‍💻 The YAML definition gets automatically adjusted any time you make changes to a workflow from the UI or via an API call. Therefore, the orchestration logic is **always managed declaratively in code**, even if you modify your workflows in other ways (UI, CI/CD, Terraform, API calls).


<p align="center">
  <img src="https://kestra.io/adding-tasks.gif" alt="Adding new tasks in the UI">
</p>

---

## 🚀 Quick Start

### Get Started Locally in 5 Minutes

#### Launch Kestra in Docker

Make sure that Docker is running. Then, start Kestra in a single command:

```bash
docker run --pull=always --rm -it -p 8080:8080 --user=root \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /tmp:/tmp kestra/kestra:latest server local
```

If you're on Windows and use PowerShell:
```powershell
docker run --pull=always --rm -it -p 8080:8080 --user=root `
    -v "/var/run/docker.sock:/var/run/docker.sock" `
    -v "C:/Temp:/tmp" kestra/kestra:latest server local
```

If you're on Windows and use Command Prompt (CMD):
```cmd
docker run --pull=always --rm -it -p 8080:8080 --user=root ^
    -v "/var/run/docker.sock:/var/run/docker.sock" ^
    -v "C:/Temp:/tmp" kestra/kestra:latest server local
```

If you're on Windows and use WSL (Linux-based environment in Windows):
```bash
docker run --pull=always --rm -it -p 8080:8080 --user=root \
    -v "/var/run/docker.sock:/var/run/docker.sock" \
    -v "C:/Temp:/tmp" kestra/kestra:latest server local
```

Check our [Installation Guide](https://kestra.io/docs/installation) for other deployment options (Docker Compose, Podman, Kubernetes, AWS, GCP, Azure, and more).

Access the Kestra UI at [http://localhost:8080](http://localhost:8080) and start building your first flow!

#### Your First Hello World Flow

Create a new flow with the following content:

```yaml
id: hello_world
namespace: dev

tasks:
  - id: say_hello
    type: io.kestra.plugin.core.log.Log
    message: "Hello, World!"
```


Run the flow and see the output in the UI!

---

## 🧩 Plugin Ecosystem

Kestra's functionality is extended through a rich [ecosystem of plugins](https://kestra.io/plugins) that empower you to run tasks anywhere and code in any language, including Python, Node.js, R, Go, Shell, and more. Here's how Kestra plugins enhance your workflows:

- **Run Anywhere:**
  - **Local or Remote Execution:** Execute tasks on your local machine, remote servers via SSH, or scale out to serverless containers using [Task Runners](https://kestra.io/docs/task-runners).
  - **Docker and Kubernetes Support:** Seamlessly run Docker containers within your workflows or launch Kubernetes jobs to handle compute-intensive workloads.

- **Code in Any Language:**
  - **Scripting Support:** Write scripts in your preferred programming language. Kestra supports Python, Node.js, R, Go, Shell, and others, allowing you to integrate existing codebases and deployment patterns.
  - **Flexible Automation:** Execute shell commands, run SQL queries against various databases, and make HTTP requests to interact with APIs.

- **Event-Driven and Real-Time Processing:**
  - **Real-Time Triggers:** React to events from external systems in real-time, such as file arrivals, new messages in message buses (Kafka, Redis, Pulsar, AMQP, MQTT, NATS, AWS SQS, Google Pub/Sub, Azure Event Hubs), and more.
  - **Custom Events:** Define custom events to trigger flows based on specific conditions or external signals, enabling highly responsive workflows.

- **Cloud Integrations:**
  - **AWS, Google Cloud, Azure:** Integrate with a variety of cloud services to interact with storage solutions, messaging systems, compute resources, and more.
  - **Big Data Processing:** Run big data processing tasks using tools like Apache Spark or interact with analytics platforms like Google BigQuery.

- **Monitoring and Notifications:**
  - **Stay Informed:** Send messages to Slack channels, email notifications, or trigger alerts in PagerDuty to keep your team updated on workflow statuses.

Kestra's plugin ecosystem is continually expanding, allowing you to tailor the platform to your specific needs. Whether you're orchestrating complex data pipelines, automating scripts across multiple environments, or integrating with cloud services, there's likely a plugin to assist. And if not, you can always [build your own plugins](https://kestra.io/docs/plugin-developer-guide/) to extend Kestra's capabilities.

🧑‍💻 **Note:** This is just a glimpse of what Kestra plugins can do. Explore the full list on our [Plugins Page](https://kestra.io/plugins).

---

## 📚 Key Concepts

- **Flows:** the core unit in Kestra, representing a workflow composed of tasks.
- **Tasks:** individual units of work, such as running a script, moving data, or calling an API.
- **Namespaces:** logical grouping of flows for organization and isolation.
- **Triggers:** schedule or events that initiate the execution of flows.
- **Inputs & Variables:** parameters and dynamic data passed into flows and tasks.

---

## 🎨 Build Workflows Visually

Kestra provides an intuitive UI that allows you to interactively build and visualize your workflows:

- **Drag-and-Drop Interface:** add and rearrange tasks from the Topology Editor.
- **Real-Time Validation:** instant feedback on your workflow's syntax and structure to catch errors early.
- **Auto-Completion:** smart suggestions as you type to write flow code quickly and without syntax errors.
- **Live Topology View:** see your workflow as a Directed Acyclic Graph (DAG) that updates in real-time.

---


## 🔧 Extensible and Developer-Friendly

### Plugin Development

Create custom plugins to extend Kestra's capabilities. Check out our [Plugin Developer Guide](https://kestra.io/docs/plugin-developer-guide/) to get started.

### Infrastructure as Code

- **Version Control:** store your flows in Git repositories.
- **CI/CD Integration:** automate deployment of flows using CI/CD pipelines.
- **Terraform Provider:** manage Kestra resources with the [official Terraform provider](https://kestra.io/docs/terraform/).

---

## 🌐 Join the Community

Stay connected and get support:

- **Slack:** Join our [Slack community](https://kestra.io/slack) to ask questions and share ideas.
- **LinkedIn:** Follow us on [LinkedIn](https://www.linkedin.com/company/kestra/) — next to Slack and GitHub, this is our main channel to share updates and product announcements.
- **YouTube:** Subscribe to our [YouTube channel](https://www.youtube.com/@kestra-io) for educational video content. We publish new videos every week!
- **X:** Follow us on [X](https://x.com/kestra_io) if you're still active there.

---

## 🚀 Enhanced Features

This enhanced version of Kestra includes powerful new capabilities that extend the core platform:

### 🤖 AI Copilot Integration
- **Natural Language Workflow Generation**: Convert plain English descriptions into complete Kestra YAML workflows
- **Multi-Provider Support**: Integrated with Google Gemini, OpenAI GPT, and Anthropic Claude
- **Interactive Chat Interface**: Get help, explanations, and suggestions through an AI-powered assistant
- **Flow Refinement**: Improve existing workflows with AI-powered suggestions and optimizations

### 📱 Apps Management
- **Complete CRUD Operations**: Create, read, update, and delete workflow applications
- **Execution Tracking**: Monitor app performance with detailed execution metrics
- **Status Management**: Track app lifecycle states (draft, active, inactive, archived)
- **Advanced Filtering**: Powerful search and filter capabilities with custom query language
- **Bulk Operations**: Manage multiple apps simultaneously

### 🧪 Tests Suite
- **Comprehensive Testing Framework**: Create and manage test suites for your workflows
- **CI/CD Integration**: Automated testing capabilities for continuous integration
- **Success Rate Tracking**: Monitor test performance with detailed statistics
- **Test Results Analysis**: Detailed reporting and analysis of test outcomes
- **Automated Test Generation**: AI-powered test case generation

### 📋 Custom Blueprints
- **Organization Templates**: Create and share workflow templates within your organization
- **Template Management**: Full lifecycle management for blueprint templates
- **Usage Tracking**: Monitor template adoption and usage patterns
- **Import/Export**: Share templates across different environments

### 🔐 Secure API Key Management
- **Encrypted Local Storage**: API keys are encrypted and stored securely in your browser
- **Multi-Provider Support**: Manage keys for multiple AI providers
- **Key Validation**: Test API keys before saving to ensure they work
- **Import/Export**: Backup and restore API key configurations

---

## 🛠️ Local Development Setup

### Prerequisites

Before setting up Kestra locally, ensure you have the following installed:

- **Java 21+** (OpenJDK or Oracle JDK)
- **Node.js 18+** and **npm** (for UI development)
- **Docker** (optional, for containerized setup)
- **Git** (for version control)

### Quick Start (Development)

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Zeeeepa/kestra.git
   cd kestra
   ```

2. **Backend Setup**
   ```bash
   # Build the backend
   ./gradlew build -x test
   
   # Start the Kestra server
   ./gradlew run
   ```

3. **Frontend Setup (UI)**
   ```bash
   # Navigate to UI directory
   cd ui
   
   # Install dependencies
   npm install
   
   # Start development server
   npm run dev
   ```

4. **Access the Application**
   - Backend API: http://localhost:8080
   - Frontend UI: http://localhost:3000 (development server)
   - Production UI: http://localhost:8080 (when backend serves UI)

### Production Setup

1. **Build for Production**
   ```bash
   # Build the complete application
   ./gradlew build
   
   # Build UI for production
   cd ui && npm run build
   ```

2. **Run Production Build**
   ```bash
   # Start Kestra with production UI
   java -jar build/libs/kestra-*.jar server standalone
   ```

3. **Docker Setup (Alternative)**
   ```bash
   # Build Docker image
   docker build -t kestra-enhanced .
   
   # Run container
   docker run -p 8080:8080 kestra-enhanced
   ```

### Environment Configuration

Create a `.env` file in the root directory:

```env
# Database Configuration
KESTRA_DATASOURCE_URL=jdbc:h2:mem:kestra
KESTRA_DATASOURCE_USERNAME=sa
KESTRA_DATASOURCE_PASSWORD=

# Server Configuration
KESTRA_SERVER_PORT=8080
KESTRA_SERVER_HOST=localhost

# Storage Configuration
KESTRA_STORAGE_TYPE=local
KESTRA_STORAGE_LOCAL_BASE_PATH=./storage

# Security Configuration
KESTRA_SECURITY_BASIC_ENABLED=false

# Feature Flags
KESTRA_FEATURES_AI_ENABLED=true
KESTRA_FEATURES_APPS_ENABLED=true
KESTRA_FEATURES_TESTS_ENABLED=true
```

### UI Development Configuration

Create `ui/.env.development`:

```env
# API Configuration
VITE_API_URL=http://localhost:8080
VITE_WS_URL=ws://localhost:8080

# Feature Flags
VITE_ENABLE_AI_FEATURES=true
VITE_ENABLE_APPS=true
VITE_ENABLE_TESTS=true
VITE_ENABLE_CUSTOM_BLUEPRINTS=true

# Development Settings
VITE_DEV_MODE=true
VITE_LOG_LEVEL=debug
```

### AI Integration Setup

To use the AI-powered features, you'll need to configure API keys:

1. **Access Settings**: Navigate to the settings page in the UI
2. **Configure API Keys**: Add your API keys for one or more providers:
   - **Google Gemini**: Get your key from [Google AI Studio](https://makersuite.google.com/app/apikey)
   - **OpenAI**: Get your key from [OpenAI Platform](https://platform.openai.com/api-keys)
   - **Anthropic**: Get your key from [Anthropic Console](https://console.anthropic.com/account/keys)

3. **Test Configuration**: Use the built-in test functionality to verify your API keys work correctly

### Database Setup (Optional)

For production use, configure a persistent database:

**PostgreSQL:**
```env
KESTRA_DATASOURCE_URL=jdbc:postgresql://localhost:5432/kestra
KESTRA_DATASOURCE_USERNAME=kestra
KESTRA_DATASOURCE_PASSWORD=your_password
KESTRA_DATASOURCE_DRIVER=org.postgresql.Driver
```

**MySQL:**
```env
KESTRA_DATASOURCE_URL=jdbc:mysql://localhost:3306/kestra
KESTRA_DATASOURCE_USERNAME=kestra
KESTRA_DATASOURCE_PASSWORD=your_password
KESTRA_DATASOURCE_DRIVER=com.mysql.cj.jdbc.Driver
```

### Troubleshooting

**Common Issues:**

1. **Port Already in Use**
   ```bash
   # Check what's using port 8080
   lsof -i :8080
   
   # Kill the process or use a different port
   KESTRA_SERVER_PORT=8081 ./gradlew run
   ```

2. **Node.js Version Issues**
   ```bash
   # Use Node Version Manager
   nvm install 18
   nvm use 18
   ```

3. **Java Version Issues**
   ```bash
   # Check Java version
   java -version
   
   # Set JAVA_HOME if needed
   export JAVA_HOME=/path/to/java21
   ```

4. **Build Failures**
   ```bash
   # Clean and rebuild
   ./gradlew clean build
   
   # Skip tests if needed
   ./gradlew build -x test
   ```

5. **UI Development Issues**
   ```bash
   # Clear npm cache
   npm cache clean --force
   
   # Delete node_modules and reinstall
   rm -rf node_modules package-lock.json
   npm install
   ```

### Development Workflow

1. **Backend Changes**: Restart the Gradle run task
2. **Frontend Changes**: Hot reload is enabled in development mode
3. **Database Changes**: Use Flyway migrations in `src/main/resources/migrations/`
4. **Plugin Development**: Follow the [Plugin Developer Guide](https://kestra.io/docs/plugin-developer-guide/)

### Testing

```bash
# Run backend tests
./gradlew test

# Run UI tests
cd ui && npm test

# Run integration tests
./gradlew integrationTest

# Run specific test
./gradlew test --tests "io.kestra.core.services.FlowServiceTest"
```

### Contributing to Enhanced Features

When contributing to the enhanced features:

1. **Apps/Tests Components**: Located in `ui/src/components/apps/` and `ui/src/components/tests/`
2. **AI Integration**: Located in `ui/src/services/aiService.ts` and `ui/src/components/ai/`
3. **API Key Management**: Located in `ui/src/utils/apiKeyStorage.ts`
4. **Translations**: Add new keys to `ui/src/translations/apps-tests-ai.json`

---

## 🤝 Contributing

We welcome contributions of all kinds!

- **Report Issues:** Found a bug or have a feature request? Open an [issue on GitHub](https://github.com/kestra-io/kestra/issues).
- **Contribute Code:** Check out our [Contributor Guide](https://kestra.io/docs/getting-started/contributing) for initial guidelines, and explore our [good first issues](https://go.kestra.io/contributing) for beginner-friendly tasks to tackle first.
- **Develop Plugins:** Build and share plugins using our [Plugin Developer Guide](https://kestra.io/docs/plugin-developer-guide/).
- **Contribute to our Docs:** Contribute edits or updates to keep our [documentation](https://github.com/kestra-io/docs) top-notch.

---

## 📄 License

Kestra is licensed under the Apache 2.0 License © [Kestra Technologies](https://kestra.io).

---

## ⭐️ Stay Updated

Give our repository a star to stay informed about the latest features and updates!

[![Star the Repo](https://kestra.io/star.gif)](https://github.com/kestra-io/kestra)

---

Thank you for considering Kestra for your workflow orchestration needs. We can't wait to see what you'll build!
