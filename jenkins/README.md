# jenkins-headless

A zero-interaction Jenkins environment configured entirely via environment variables. Perfect for automation, CI/CD pipelines, and Docker containers.

## Features

- ✅ **Zero interaction required** - Fully automated setup
- ✅ **Runtime configuration** - Override any setting via environment variables
- ✅ **Plugin management** - Automated plugin installation
- ✅ **Configuration as Code** - JCasC support built-in
- ✅ **Cross-platform** - Works on Linux and macOS (x86_64 and arm64)
- ✅ **Persistent storage** - Data survives environment re-activation
- ✅ **Profile functions** - Convenient management commands (bash/zsh/fish)

## Quick Start

### Start Jenkins with Defaults

```bash
cd jenkins-headless
flox activate -s
```

Jenkins will start on `http://localhost:8080` with default configuration.

### Override Configuration

```bash
# Custom port
JENKINS_PORT=9090 flox activate -s

# Custom plugins
JENKINS_PLUGINS="git workflow-aggregator prometheus" flox activate -s

# Multiple overrides
JENKINS_PORT=9090 JENKINS_PLUGINS="git workflow-aggregator" flox activate -s
```

### Access Jenkins

1. Wait for Jenkins to start (~30-60 seconds)
2. Open `http://localhost:8080` in your browser
3. Login with default credentials:
   - Username: `admin`
   - Password: `changeme` (or value from `JENKINS_ADMIN_PASSWORD`)

## Configuration

### Environment Variables

All configuration is done via environment variables that can be overridden at runtime.

| Variable | Default | Description |
|----------|---------|-------------|
| `JENKINS_PORT` | `8080` | HTTP port for Jenkins |
| `JENKINS_PREFIX` | `/` | URL prefix (e.g., `/jenkins`) |
| `JENKINS_HOME` | `$FLOX_ENV_CACHE/data/jenkins-home` | Jenkins data directory |
| `JENKINS_ADMIN_USER` | `admin` | Admin username |
| `JENKINS_ADMIN_PASSWORD` | `changeme` | Admin password |
| `JENKINS_JAVA_OPTS` | `-Xmx1g -Djava.awt.headless=true` | Java options |
| `JENKINS_PLUGINS` | `git workflow-aggregator docker-workflow github configuration-as-code` | Space-separated plugin list |
| `JENKINS_CASC_CONFIG` | `$FLOX_ENV_CACHE/config/jenkins.yaml` | JCasC configuration file |

### Secure Credentials

**Never put passwords in environment variables in production!**

**Recommended:** Store credentials in `~/.config/jenkins/credentials`:

```bash
mkdir -p ~/.config/jenkins
cat > ~/.config/jenkins/credentials << EOF
export JENKINS_ADMIN_USER="your-admin"
export JENKINS_ADMIN_PASSWORD="your-secure-password"
EOF
chmod 600 ~/.config/jenkins/credentials
```

The environment will automatically source this file if `JENKINS_ADMIN_PASSWORD` is not set.

## Available Commands

These commands are available after `flox activate`:

### `jenkins-info`

Display Jenkins configuration and status.

```bash
jenkins-info
```

**Output:**
```
Jenkins Headless Environment Configuration

Version:
2.528.1

Server:
  URL:            http://localhost:8080/
  JENKINS_HOME:   /path/to/jenkins-home
  Admin User:     admin

Configuration:
  Java Options:   -Xmx1g -Djava.awt.headless=true
  JCasC Config:   /path/to/jenkins.yaml
  Plugins:        git workflow-aggregator docker-workflow ...

Logs:
  Service Log:    /path/to/logs/jenkins.log
  Jenkins Logs:   /path/to/jenkins-home/logs/
```

### `jenkins-health`

Check if Jenkins is responding.

```bash
jenkins-health
```

**Output:**
```
✅ Jenkins is healthy
   URL: http://localhost:8080/
```

Or if not running:
```
❌ Jenkins is not responding
   URL: http://localhost:8080/login

Troubleshooting:
  1. Check if service is running: flox services status
  2. View logs: jenkins-logs
  3. Check port: netstat -tlnp | grep 8080
```

### `jenkins-logs`

Tail Jenkins service logs in real-time.

```bash
jenkins-logs
```

Press `Ctrl+C` to stop tailing.

### `jenkins-plugin-install`

Install additional plugins after Jenkins is running.

```bash
jenkins-plugin-install <plugin-name> [plugin-name...]
```

**Examples:**
```bash
# Single plugin
jenkins-plugin-install prometheus

# Multiple plugins
jenkins-plugin-install slack role-strategy matrix-auth

# After installation, restart Jenkins
flox services restart jenkins
```

### `jenkins-url`

Print Jenkins URL and optionally open in browser.

```bash
jenkins-url
```

**Output:** `http://localhost:8080/`

On Linux with `xdg-open` or macOS with `open`, this will also open the URL in your browser.

## Plugin Management

### Default Plugins

The environment installs these plugins by default:
- `git` - Git integration
- `workflow-aggregator` - Pipeline support (declarative + scripted)
- `docker-workflow` - Docker pipeline support
- `github` - GitHub integration
- `configuration-as-code` - JCasC support

### Custom Plugin Sets

Override `JENKINS_PLUGINS` to install different plugins:

**Minimal:**
```bash
JENKINS_PLUGINS="git workflow-aggregator" flox activate -s
```

**Recommended:**
```bash
JENKINS_PLUGINS="git workflow-aggregator docker-workflow github configuration-as-code" flox activate -s
```

**Full (Production):**
```bash
JENKINS_PLUGINS="git workflow-aggregator docker-workflow github configuration-as-code prometheus role-strategy matrix-auth pipeline-graph-view" flox activate -s
```

### Plugin Installation Process

Plugins are installed when the Jenkins service starts:

1. Service starts
2. Plugin Installation Manager downloads plugins
3. Plugins are installed to `$JENKINS_HOME/plugins/`
4. Jenkins starts with plugins loaded

**Note:** Plugin installation adds ~30-60 seconds to startup time, depending on the number of plugins.

## Configuration as Code (JCasC)

Jenkins is configured via JCasC YAML file located at `$FLOX_ENV_CACHE/config/jenkins.yaml`.

### Default Configuration

A default JCasC configuration is generated on first activation:

```yaml
jenkins:
  systemMessage: "Jenkins Headless Environment (Flox)"
  numExecutors: 0  # Best practice: no builds on controller
  mode: EXCLUSIVE

  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: "${JENKINS_ADMIN_USER}"
          password: "${JENKINS_ADMIN_PASSWORD:-changeme}"

  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: false

unclassified:
  location:
    url: "http://localhost:${JENKINS_PORT}${JENKINS_PREFIX}"
    adminAddress: "jenkins@localhost"
```

### Custom JCasC Configuration

1. Edit the configuration file:
   ```bash
   flox activate
   $EDITOR $FLOX_ENV_CACHE/config/jenkins.yaml
   ```

2. Restart Jenkins to apply changes:
   ```bash
   flox services restart jenkins
   ```

### JCasC Examples

**Add Kubernetes cloud:**

```yaml
jenkins:
  clouds:
    - kubernetes:
        name: "kubernetes"
        serverUrl: "https://kubernetes.default"
        namespace: "jenkins-agents"
        jenkinsUrl: "http://jenkins:8080"
        templates:
          - name: "default-agent"
            label: "linux-x86_64"
            containers:
              - name: "jnlp"
                image: "jenkins/inbound-agent:latest"
```

**Add LDAP authentication:**

```yaml
jenkins:
  securityRealm:
    ldap:
      configurations:
        - server: "ldap://ldap.example.com:389"
          rootDN: "dc=example,dc=com"
          userSearchBase: "ou=users"
```

## Service Management

### Start Jenkins

```bash
flox activate -s
# or
flox activate --start-services
```

### Check Service Status

```bash
flox services status
```

**Example output:**
```
jenkins: ✓ running [PID 12345]
```

### Stop Jenkins

```bash
flox services stop jenkins
```

### Restart Jenkins

```bash
flox services restart jenkins
```

### View Service Logs

```bash
flox services logs jenkins
# or
jenkins-logs
```

## Directory Structure

The environment creates the following directory structure:

```
$FLOX_ENV_CACHE/
├── config/
│   └── jenkins.yaml           # JCasC configuration
├── data/
│   └── jenkins-home/          # JENKINS_HOME directory
│       ├── jobs/              # Job configurations
│       ├── plugins/           # Installed plugins
│       ├── workspace/         # Build workspaces
│       └── logs/              # Jenkins logs
├── logs/
│   └── jenkins.log            # Service log
└── cache/
    └── jenkins-plugin-manager-*.jar  # Plugin installation tool
```

## Troubleshooting

### Jenkins won't start

1. **Check if port is already in use:**
   ```bash
   netstat -tlnp | grep 8080
   ```

   **Solution:** Use a different port:
   ```bash
   JENKINS_PORT=9090 flox activate -s
   ```

2. **Check service logs:**
   ```bash
   jenkins-logs
   ```

3. **Verify Java is available:**
   ```bash
   flox activate -- java -version
   ```

### Plugin installation fails

1. **Check internet connectivity:**
   ```bash
   curl -I https://updates.jenkins.io
   ```

2. **View plugin installation logs:**
   ```bash
   jenkins-logs | grep -i plugin
   ```

3. **Manual plugin installation:**
   - Download `.hpi` file from https://plugins.jenkins.io/
   - Copy to `$JENKINS_HOME/plugins/`
   - Restart Jenkins

### "jenkins.war not found" error

This means the Jenkins package isn't properly installed.

**Solution:**
```bash
flox install jenkins
```

### Permission denied errors

Check that `$JENKINS_HOME` directory is writable:

```bash
ls -la $FLOX_ENV_CACHE/data/jenkins-home
```

If permissions are wrong, fix them:
```bash
chmod -R u+w $FLOX_ENV_CACHE/data/jenkins-home
```

### Out of memory errors

Increase Java heap size:

```bash
JENKINS_JAVA_OPTS="-Xmx2g -Djava.awt.headless=true" flox activate -s
```

## Examples

### Example 1: Basic Usage

```bash
# Activate and start Jenkins
cd jenkins-headless
flox activate -s

# Wait for startup (check logs)
jenkins-logs

# In another terminal, check health
flox activate -- jenkins-health

# Open Jenkins in browser
flox activate -- jenkins-url
```

### Example 2: Custom Configuration

```bash
# Create credentials file
mkdir -p ~/.config/jenkins
cat > ~/.config/jenkins/credentials << 'EOF'
export JENKINS_ADMIN_USER="myuser"
export JENKINS_ADMIN_PASSWORD="mySecureP@ssw0rd"
EOF
chmod 600 ~/.config/jenkins/credentials

# Start with custom port and plugins
JENKINS_PORT=9090 \
JENKINS_PLUGINS="git workflow-aggregator prometheus slack" \
flox activate -s
```

### Example 3: Production Deployment

```bash
# Set production environment variables
export JENKINS_PORT=8080
export JENKINS_PREFIX="/jenkins"
export JENKINS_ADMIN_USER="admin"
export JENKINS_ADMIN_PASSWORD="$(cat /run/secrets/jenkins-password)"
export JENKINS_JAVA_OPTS="-Xmx4g -XX:+UseG1GC"
export JENKINS_PLUGINS="git workflow-aggregator docker-workflow github configuration-as-code prometheus role-strategy"

# Start Jenkins
flox activate -s
```

### Example 4: Docker Container

```dockerfile
FROM ghcr.io/flox/flox:latest

# Copy jenkins-headless environment
COPY jenkins-headless /workspace/jenkins-headless
WORKDIR /workspace/jenkins-headless

# Set environment variables
ENV JENKINS_PORT=8080 \
    JENKINS_ADMIN_USER=admin \
    JENKINS_ADMIN_PASSWORD=changeme

# Start Jenkins on container start
CMD ["flox", "activate", "-s"]
```

## Advanced Usage

### Behind Reverse Proxy

Configure nginx or another reverse proxy:

**nginx example:**
```nginx
server {
    listen 80;
    server_name jenkins.example.com;

    location /jenkins/ {
        proxy_pass http://localhost:8080/jenkins/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**Set Jenkins prefix:**
```bash
JENKINS_PREFIX="/jenkins" flox activate -s
```

### Kubernetes Deployment

Use this environment as a base for Kubernetes deployments.

**ConfigMap for JCasC:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: jenkins-config
data:
  jenkins.yaml: |
    jenkins:
      clouds:
        - kubernetes:
            name: "kubernetes"
            serverUrl: "https://kubernetes.default"
```

**Set JCasC config path:**
```bash
JENKINS_CASC_CONFIG="/config/jenkins.yaml" flox activate -s
```

### CI/CD Integration

Use in GitHub Actions, GitLab CI, or other CI/CD systems:

**.github/workflows/test-jenkins.yml:**
```yaml
name: Test Jenkins Configuration
on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: flox/install@v1
      - name: Start Jenkins
        run: |
          cd jenkins-headless
          JENKINS_PORT=8080 flox activate -s &
          sleep 60  # Wait for startup
      - name: Test Jenkins
        run: |
          cd jenkins-headless
          flox activate -- jenkins-health
```

## Best Practices

1. **Never commit secrets** - Use `~/.config/jenkins/credentials` or environment variables
2. **Pin plugin versions** - For reproducibility, specify exact plugin versions
3. **Regular backups** - Backup `$JENKINS_HOME` regularly
4. **Monitor resources** - Watch memory usage, increase `JENKINS_JAVA_OPTS` if needed
5. **Use JCasC** - Configure everything via `jenkins.yaml` for version control
6. **Test in dev first** - Always test configuration changes before production
7. **Keep Jenkins updated** - Use latest LTS version for security patches

## Version Information

- **Jenkins:** 2.528.1 (LTS)
- **Java:** OpenJDK 21.0.9
- **Plugin Manager:** 2.13.0

## Resources

- **Jenkins Documentation:** https://www.jenkins.io/doc/
- **JCasC Documentation:** https://github.com/jenkinsci/configuration-as-code-plugin
- **Plugin Index:** https://plugins.jenkins.io/
- **Flox Documentation:** https://flox.dev/docs

## License

This Flox environment configuration is provided as-is. Jenkins itself is licensed under the MIT License.

## Contributing

Found an issue or have a suggestion? Please report it!

---

**Need the interactive version?** Check out the `jenkins` environment for a guided setup wizard using `gum`.
