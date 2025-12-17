# Legacy Internal Documentation

**Purpose:** Historical reference for app-specific implementation documentation.

**Scope:** Internal Azure OpenAI framework documentation, examples, and legacy implementation notes.

**Audience:** Internal development team.

**Status:** This directory is deprecated for new documentation. See `/YC EDIFY/docs/` for current internal documentation and `/documentation/` for enterprise-level technical documentation.

---

## Deprecation Notice

This directory (`/YC EDIFY/documentation/`) contains legacy internal documentation that has been reorganized. Most content has been moved to:

- **`/documentation/`** - Enterprise-level technical documentation (architecture, deployment, operations, security)
- **`/YC EDIFY/docs/`** - Internal app-specific documentation hub (features, experiments, app logic, configs)

**What remains here:**
- Azure OpenAI framework reference documentation (`/framework/`)
- Implementation examples for reference (`/examples/`)
- A few legacy deployment and authentication guides

**For current documentation, see:**
- Main documentation: `/documentation/README.md`
- Internal docs hub: `/YC EDIFY/docs/README.md`
- Project overview: `/YC EDIFY/README.md`

---

## Remaining Content

### Azure OpenAI Framework Reference (`/framework/`)

Original Azure OpenAI sample framework documentation. This is external reference documentation and remains in place for framework-specific guidance.

**Key Files:**
- `README.md` - Framework overview and advanced topics
- `localdev.md` - Local development setup for framework
- `customization.md` - Framework customization guide
- `deploy_troubleshooting.md` - Framework deployment troubleshooting
- Additional 16+ framework-specific guides

### Implementation Examples (`/examples/`)

Sample implementations demonstrating various RAG patterns and integrations.

**Available Examples:**
- `chat/` - ChatGPT-like app implementation
- `data-ingestion/` - Data ingestion patterns
- `document-security/` - Security implementation examples
- `private-endpoint/` - Private endpoint configuration

### Authentication (`/auth/`)

- `GOOGLE_OAUTH_SETUP.md` - Google OAuth configuration guide (also in `/documentation/`)

### Deployment (`/deployment/`)

- `PRODUCTION_GUIDE.md` - Production deployment guide (also in `/documentation/`)

---

## Migration Guide

**If you are looking for:**

| Old Location | New Location | Type |
|--------------|--------------|------|
| Authentication architecture | `/documentation/backend/authentication.md` | Enterprise docs |
| Deployment procedures | `/documentation/deployment/` | Enterprise docs |
| Feature implementation notes | `/YC EDIFY/docs/features/` | Internal docs |
| App logic details | `/YC EDIFY/docs/app-logic/` | Internal docs |
| Configuration guides | `/YC EDIFY/docs/configs-and-scripts/` | Internal docs |
| Experimental features | `/YC EDIFY/docs/experiments/` | Internal docs |
| Completion reports | `/YC EDIFY/docs/old/completion-reports/` | Historical |

---

**Last Updated:** 2025-09-30 - Documentation restructuring completed

**Note:** This directory is maintained for historical reference only. Do not add new documentation here.
