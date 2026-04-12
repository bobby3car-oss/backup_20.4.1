---
name: security-auditor
description: "Use when reviewing authentication flows, data handling, API endpoints, or any security-sensitive code. Checks for OWASP Top 10 vulnerabilities, insecure data storage, missing input validation, and authorization gaps."
---

# Security Auditor

## Overview

Security-focused code review that checks for vulnerabilities before they ship. Not a replacement for penetration testing, but catches the issues that code review typically misses because reviewers aren't thinking adversarially.

**Core principle:** Think like an attacker reviewing every code change.

## When to Use

- Reviewing authentication or authorization code
- Handling user input or data
- Working with API endpoints or network calls
- Storing sensitive data (credentials, tokens, PII)
- Modifying Firestore rules or security configuration
- Before any deployment

## OWASP Top 10 Checklist

### 1. Injection
- [ ] All user input parameterized (no string concatenation in queries)
- [ ] Firestore queries use typed parameters
- [ ] No `eval()` or dynamic code execution

### 2. Broken Authentication
- [ ] Password/token storage uses platform secure storage (Keychain/Keystore)
- [ ] Session tokens have expiration
- [ ] OAuth flows use PKCE
- [ ] No hardcoded credentials or API keys

### 3. Sensitive Data Exposure
- [ ] PII encrypted at rest and in transit
- [ ] No sensitive data in logs or error messages
- [ ] No secrets in source code or version control
- [ ] Proper data minimization (don't store what you don't need)

### 4. Broken Access Control
- [ ] Every Firestore rule enforces ownership checks
- [ ] Role-based access properly validated server-side
- [ ] No client-side-only authorization checks
- [ ] IDOR prevention (users can't access other users' data by guessing IDs)

### 5. Security Misconfiguration
- [ ] Debug modes disabled in production builds
- [ ] Firestore rules not overly permissive
- [ ] CORS properly configured
- [ ] No default credentials

### 6. XSS (Cross-Site Scripting)
- [ ] WebView content properly sanitized
- [ ] Deep links validated before processing
- [ ] No `innerHTML` equivalent in web views

### 7. Insecure Data Storage (Mobile-Specific)
- [ ] Sensitive data in secure storage, not SharedPreferences/UserDefaults
- [ ] No sensitive data in clipboard
- [ ] Screenshot protection for sensitive screens
- [ ] No sensitive data in app backups

### 8. Insufficient Transport Security
- [ ] All network calls use HTTPS
- [ ] Certificate pinning for sensitive APIs
- [ ] No bypass of SSL verification

### 9. Broken Cryptography
- [ ] Using platform-provided crypto (no custom implementations)
- [ ] Adequate key lengths
- [ ] Proper random number generation

### 10. Insufficient Input Validation
- [ ] Email, phone, URL validation at boundaries
- [ ] File upload type and size validation
- [ ] Deep link parameter validation
- [ ] Form input sanitization

## Flutter/Firebase Specific Checks

- [ ] Firestore rules match application logic
- [ ] Cloud Functions validate caller authentication
- [ ] Firebase Auth error messages don't leak user existence
- [ ] Push notification tokens stored securely
- [ ] App Check enabled for API protection

## Process

1. **Identify security-sensitive code** in the changes
2. **Run through checklist** systematically
3. **Flag findings** with severity (Critical/High/Medium/Low)
4. **Fix Critical and High** immediately
5. **Document Medium and Low** for tracking

## Severity

| Level | Definition | Action |
|-------|-----------|--------|
| **Critical** | Exploitable now, data at risk | Fix before any deployment |
| **High** | Exploitable with effort | Fix in current sprint |
| **Medium** | Defense-in-depth gap | Plan fix |
| **Low** | Best practice deviation | Note for improvement |
