# Go Module Proxy Enhancement Plan for GHEC Migration Support

✅ Executive Summary
To ensure our internal proxy supports Golang modules migrated from GitHub Enterprise Server (GHES) to GitHub Enterprise Cloud (GHEC), we propose enhancing the proxy to intercept and rewrite go get meta tag responses. This allows legacy module paths to resolve seamlessly—even when repository URLs change—without requiring all internal developers to update code immediately.

This is a moderate-effort change that will yield high impact, unlocking developer productivity and reducing post-migration risk.

🧩 What Needs to Be Built
1. Go ?go-get=1 Meta Tag Handling
Parse go get requests that include ?go-get=1

Identify if the requested path maps to a migrated repository

Return HTML meta tags that point to the new GHEC repo

For example, convert github.old.com/org/pkg → github.new.com/org/pkg in the go-import meta tag.

2. Module Path Compatibility Logic
Support scenarios where:

Module import paths are old, but repos are migrated

replace directives redirect to new locations

Both import paths and module paths have been updated

Ensure fallback behavior if module path mismatches occur.

3. Proxy Logging and Observability
Log all go get interception activity for traceability

Flag mismatched module names vs import paths

Enable request tracing to help debug issues in CI/dev

4. Security Considerations
Ensure only internal domains (e.g., github.old.com) are intercepted

Enforce HTTPS for proxy communications

Honor GOPRIVATE, GOINSECURE, and other Go environment variables appropriately

📅 Timeline (4–5 Weeks)
Week	Task	Output
1	Requirements review, internal Go use case audit, and initial prototype	Final spec, test matrix
2	Implement meta tag rewriting logic	Proxy returns rewritten go-import tag
3	Add compatibility for replace directives, old/new module names	All resolution paths covered
4	Logging, metrics, and observability	Tracing and logs available
5	Testing across real modules (direct, transitive, vendored), deploy to test environment	Release candidate ready

📦 Level of Effort
Component	Estimate
Meta tag interception	3–4 days
Module compatibility logic	4–5 days
Proxy config and env vars	2–3 days
Observability/logging	2–3 days
Automated testing + CI	3–4 days
Total (with buffer)	~4–5 weeks

Effort is medium, but risk is low to moderate, since all changes can be isolated behind a flag or route (/go-get).

✅ Benefits
Zero-friction support for legacy Go modules post-GHEC migration

No need to mass-update go.mod files or import paths immediately

Ensures vendor, replace, and transitive dependencies resolve correctly

Enables incremental migration without developer pain

🧪 Test Coverage
We have authored a comprehensive Behave test suite that verifies:

Old paths resolving via the proxy

replace behavior

Module name mismatch detection

Vendoring upgrades/downgrades

Transitive and mono-repo dependencies

This will ensure confidence before rollout and can be used as a regression suite for future proxy changes.

🚀 Rollout Plan

1. Staging Deployment
- Enable internal proxy in staging VPC
- Validate using test scenarios and real Go services

2. Incremental Dev Rollout
- Enable in dev environments of selected teams
- Gather feedback and error traces

3. Full Production Deployment
- Turn on proxy support for all Go services
- Monitor logs for mismatches and failures

📢 Communication Guidance for GOLANG PLEC Team

GOLANG PLEC should notify developers to switch their git configuration to use HTTPS instead of SSH for go-get requests if they want to benefit from automatic redirects handled by the internal proxy.

If users continue to use SSH-based import paths, the proxy will be bypassed and they will need to manually update their import paths after migration.

Recommend enforcing or suggesting HTTPS in developer onboarding and tooling to ensure smoother migration experience across teams.


📅 Timeline: 4–5 Weeks

Week 1: Planning & Prototyping

Finalize technical requirements

Map out enterprise Go module usage

Build prototype for go-get meta tag interception

Week 2: Core Meta Tag Rewriting

Implement logic to intercept ?go-get=1 requests

Rewrite meta tags to new GHEC repo URLs

Validate module download works via new URLs

Week 3: Compatibility Enhancements

Add logic to handle:

replace directives

mismatched module names and import paths

legacy module declarations

Validate behavior with mixed module states

Week 4: Logging, Observability, Testing

Add request logging and trace flags to proxy

Build integration test cases using Behave

Enable support for vendoring workflows

Week 5: Pre-Production Rollout

Deploy proxy changes to staging/test VPC

Validate with sample real-world Go services

Prepare rollout documentation & cut release