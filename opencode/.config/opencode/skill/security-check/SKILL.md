---
name: security-check
description: Security audit patterns for identifying vulnerabilities and security issues
---

# Security Check Skill

Use this skill when auditing code for security vulnerabilities or reviewing security-sensitive changes.

## Security Review Questions

When reviewing security-sensitive code, ask:

1. **What could go wrong?** - Assume adversarial input.
2. **What's the blast radius?** - If this fails, what's exposed?
3. **Is this the right layer?** - Is security enforced at the right level?
4. **Can this be bypassed?** - Are there alternate paths to the resource?
5. **Is this defense in depth?** - Are there multiple layers of protection?

## Common Vulnerability Patterns

### Injection Attacks

#### SQL Injection

```python
# Bad
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")

# Good
cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
```

#### Command Injection

```python
# Bad
os.system(f"convert {filename} output.png")

# Good
subprocess.run(["convert", filename, "output.png"], check=True)
```

#### Path Traversal

```python
# Bad
open(f"/uploads/{user_filename}")

# Good
safe_path = os.path.realpath(os.path.join("/uploads", user_filename))
if not safe_path.startswith("/uploads/"):
    raise ValueError("Invalid path")
```

#### SSRF (Server-Side Request Forgery)

```python
# Bad - user controls the URL
response = requests.get(user_provided_url)

# Good - validate against allowlist
ALLOWED_HOSTS = ["api.example.com", "cdn.example.com"]
parsed = urlparse(user_provided_url)
if parsed.hostname not in ALLOWED_HOSTS:
    raise ValueError("URL not allowed")
```

#### Insecure Deserialization

```python
# Bad - arbitrary code execution
data = pickle.loads(user_input)
result = eval(user_expression)

# Good - use safe alternatives
data = json.loads(user_input)
```

### JWT Security

```python
# Bad - algorithm not specified, vulnerable to "none" attack
payload = jwt.decode(token, options={"verify_signature": False})

# Good - explicit algorithm and full validation
payload = jwt.decode(
    token, 
    key=SECRET_KEY, 
    algorithms=["HS256"],
    audience="my-app",
    issuer="auth.example.com",
)
```

### Secrets & Credentials

```python
# Bad
API_KEY = "sk-1234567890abcdef"

# Good
API_KEY = os.environ["API_KEY"]
```

### Cryptography

```python
# Bad - for security purposes
hashlib.md5(password.encode()).hexdigest()

# Good
import bcrypt
bcrypt.hashpw(password.encode(), bcrypt.gensalt())
```

### Dependency Scanning

Check with:
- `npm audit` / `yarn audit` (Node.js)
- `pip-audit` / `safety check` (Python)
- `govulncheck` (Go)

## Security Checklist

### Input Validation
- [ ] Is all user input validated before use?
- [ ] Are inputs sanitized for the context (HTML, SQL, shell, filesystem)?
- [ ] Are length limits enforced on strings and arrays?
- [ ] Are numeric inputs validated for range and type?
- [ ] Is file upload validated (type, size, content)?

### Injection Prevention
- [ ] Are parameterized queries/prepared statements used?
- [ ] Is raw string concatenation avoided in SQL?
- [ ] Are ORM queries reviewed for dynamic field injection?
- [ ] Is user input ever passed to shell commands?
- [ ] Are subprocess calls using shell=False with argument lists?

### XSS Prevention
- [ ] Is user content HTML-escaped before rendering?
- [ ] Is dangerouslySetInnerHTML (React) or equivalent avoided?
- [ ] Are Content-Security-Policy headers configured?

### Path & URL Safety
- [ ] Are file paths validated to prevent directory traversal?
- [ ] Is user input used in file paths sanitized?
- [ ] Is user input used in URLs validated against allowlists?
- [ ] Are internal/private IP ranges blocked for user-provided URLs?

### Deserialization
- [ ] Is pickle/eval/exec avoided on user input?
- [ ] Are JSON/YAML parsers configured safely?
- [ ] Is untrusted data never passed to `eval()`, `exec()`, or `Function()`?

### Authentication & Authorization
- [ ] Is authentication required for sensitive endpoints?
- [ ] Are authorization checks performed on every request?
- [ ] Is the principle of least privilege applied?
- [ ] Are authentication tokens validated correctly?
- [ ] Is session management secure (secure cookies, expiration)?
- [ ] Are password reset flows secure?

### JWT Security
- [ ] Is the algorithm explicitly specified (never accept "none")?
- [ ] Is the secret/key sufficiently strong (256+ bits)?
- [ ] Are tokens validated for expiration (exp), audience (aud), issuer (iss)?
- [ ] Is the token type verified (access vs refresh)?
- [ ] Are tokens stored securely (httpOnly cookies, not localStorage)?

### Secrets & Credentials
- [ ] Are there hardcoded secrets, API keys, or passwords?
- [ ] Are secrets loaded from environment variables or secret managers?
- [ ] Are secrets excluded from logs and error messages?
- [ ] Is .env or credentials file in .gitignore?
- [ ] Are default credentials changed?

### Cryptography
- [ ] Are deprecated algorithms avoided (MD5, SHA1 for security, DES)?
- [ ] Is password hashing using bcrypt, scrypt, or argon2?
- [ ] Are random values using cryptographically secure generators?
- [ ] Are encryption keys properly managed?

### Data Exposure
- [ ] Is sensitive data (PII, credentials) excluded from logs?
- [ ] Are API responses minimal (no unnecessary data)?
- [ ] Is sensitive data encrypted at rest?
- [ ] Are error messages generic to users but detailed in logs?
- [ ] Is debug mode disabled in production?

### Dependencies
- [ ] Are dependencies up to date?
- [ ] Are there known vulnerabilities in dependencies?
- [ ] Are dependency sources trusted?
- [ ] Is lockfile committed to prevent dependency confusion?

### Rate Limiting & DoS
- [ ] Are rate limits applied to authentication endpoints?
- [ ] Are rate limits applied to expensive operations?
- [ ] Is there protection against resource exhaustion?
- [ ] Are timeouts configured for external requests?

### CORS & Headers
- [ ] Is CORS configured restrictively?
- [ ] Are security headers set (X-Content-Type-Options, X-Frame-Options)?
- [ ] Is HTTPS enforced?
