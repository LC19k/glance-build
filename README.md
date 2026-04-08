# Glance Build Pipeline (Homelab Edition)

This repository contains a clean, stable, upstream‑aware build pipeline for the [Glance](https://github.com/glanceapp/glance) dashboard. It produces two types of images:

- **Stable** — manually triggered, pinned to a specific upstream commit  
- **Nightly** — automatically built only when upstream changes  

The pipeline is optimized for homelab use:

- amd64‑only  
- minimal maintenance  
- no wasted CI cycles  
- clear, narratable tags  
- reproducible stable builds  
- safe nightly experimentation  

---

## 🏷️ Tagging Model

| Tag | Meaning | Source |
|-----|---------|--------|
| `stable` | Your pinned, trusted deployment version | Manual build |
| `latest` | Most recent upstream commit | Nightly build |
| `nightly‑YYYYMMDD` | Date‑stamped nightly snapshot | Nightly build |
| `sha‑<commit>` | Exact upstream commit | Both |

This gives you clarity, traceability, and zero ambiguity.

---

## 🏗️ Build Types

### **Stable Build (manual)**  
- Triggered via **Run workflow**  
- Uses a pinned upstream commit  
- Produces:  
  - `stable`  
  - `sha‑<commit>`  
- Never overwritten  
- Safe for long‑term homelab deployment  

### **Nightly Build (automatic)**  
- Runs nightly at 04:00 UTC  
- Checks upstream Glance repo  
- **Only builds if upstream changed**  
- Produces:  
  - `latest`  
  - `nightly‑YYYYMMDD`  
  - `sha‑<commit>`  
- Never overwrites `stable`  

---

## 🧬 Upstream‑Change Detection

Nightly builds use GHCR metadata to detect whether the upstream Glance commit has changed.

1. Fetch upstream HEAD SHA  
2. Fetch last built SHA from GHCR image label  
3. Compare  
4. Skip build if identical  

This ensures:

- no wasted CI minutes  
- no unnecessary GHCR churn  
- no tag spam  
- no accidental overwrites  

---

## 🐳 Dockerfile Overview

The Dockerfile:

- pins Go version  
- supports pinned Glance refs  
- builds from repo root  
- produces a minimal Alpine runtime image  

It supports both stable and nightly builds via:

```
ARG GLANCE_REF=<commit or main>
```

---

## 🚀 How to Update the Stable Build

When you want to upgrade your homelab deployment:

1. Visit **Actions → Build & Publish Glance**  
2. Click **Run workflow**  
3. Enter the upstream commit you want to pin to  
   - Example:  
     ```
     2aef3df44babcdfd7e03407303b965d904d08cbc
     ```
4. Run the workflow  
5. Deploy the new `stable` tag  

### Why this is safe  
You always know exactly what commit you’re running.  
Your deployment never auto‑updates.  
You choose when to upgrade.

---

## 🧪 How to Test Nightly Builds Safely

Nightly builds track upstream `main` and may include:

- new features  
- experimental changes  
- breaking changes  

To test safely:

1. Pull the nightly image:
   ```
   docker pull ghcr.io/lc19k/glance:latest
   ```
2. Run it in a temporary container:
   ```
   docker run --rm -p 8080:8080 ghcr.io/lc19k/glance:latest
   ```
3. Verify:
   - UI loads  
   - config still works  
   - no regressions  
4. If it looks good, you can promote it to stable by running a manual stable build pinned to that commit.

### Why this is safe  
Nightly builds **never** overwrite your stable deployment.  
You can test without risk.

---

## 🛠️ How to Pin a Specific Upstream Commit

If you want to lock to a known‑good version:

1. Find the commit in the upstream repo  
2. Run the stable workflow with:
   ```
   glance_ref=<commit>
   ```
3. Deploy the `stable` tag  

This gives you reproducible builds forever.

---

## 🔍 How to See What Changed Upstream

Nightly builds include:

- `sha‑<commit>` tag  
- `org.opencontainers.image.revision` label  

You can inspect the image:

```
docker manifest inspect ghcr.io/lc19k/glance:latest | jq .
```

This shows the exact upstream commit used.

---

## 🔐 Optional: SBOM + Provenance

The workflow is structured so SBOM + provenance can be added later with minimal changes.  
If you decide to adopt Kubernetes, GitOps, or supply‑chain tooling, you’re already 90% of the way there.

---

## 🧹 Why This Pipeline Is Ideal for a Homelab

- **Stable** is rock‑solid and pinned  
- **Nightly** is fresh but safe  
- No surprise breakage  
- No wasted CI cycles  
- No multi‑arch overhead  
- No external state  
- No bot commits  
- No maintenance burden  
- Clear, narratable tags  
- Easy to reason about months later  

This is the kind of pipeline you can forget about until you actually want to update something.
