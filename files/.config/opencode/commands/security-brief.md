---
description: Summarize recent security posts from Socket, StepSecurity, Snyk, and Wiz
---

Create a concise security bulletin from the latest blog posts from these sources:

- Socket: https://socket.dev/blog/category/security-news
- StepSecurity: https://www.stepsecurity.io/blog?category=Threat+Intel
- Snyk: https://snyk.io/blog/?topic=vulnerability-insights
- Wiz: https://www.wiz.io/blog/tag/security

For each source:

- Identify dated blog posts from newest to oldest, starting with the newest post on the listing page
- Ignore product announcements, though leadership and generic AI posts
- Fetch posts from the last three days
- Focus on compromises, malicious packages, CI/CD abuse, cloud incidents, exploited vulnerabilities, credential theft, and supply-chain attacks.

Deduplicate incidents reported by multiple sources. Keep all source links for a deduplicated incident, but summarize the incident once. Use this output format:

```md
# Security Bulletin

## Overview

- Shared campaigns, repeated indicators, recurring attacker behavior, or ecosystem trends. If no cross-source trend is visible, say `No cross-source trend identified.`

## Source Status

- Socket: OK, or describe fetch/parse issues.
- StepSecurity: OK, or describe fetch/parse issues.
- Snyk: OK, or describe fetch/parse issues.
- Wiz: OK, or describe fetch/parse issues.

## <Date>: <Incident> (<Criticality>)

<Summary>

### Affected

- List of affected applications, packages, repositories etc

### Sources

- Links to the blog posts about the incident
```

Severity guidance:

- Critical: active compromise, malicious package/version, credential theft, CI/CD or cloud token abuse, or known exploitation requiring immediate action.
- High: credible exploit path or serious vulnerability with likely exposure, but no confirmed active compromise in the reviewed posts.
- Medium: useful defensive research or hardening guidance with indirect operational relevance.
- Info: product news, general commentary, or background context.

Keep the bulletin easy to scan. Prefer short bullets and tables over long prose. If a source cannot be fetched or parsed, include that in `Source Status` and continue with the other sources.
