# BrinaOS Skill

id: brinaos
name: BrinaOS
description: Port ColorOS / Realme UI to Snapdragon 865, 870, and 888 devices using the BrinaOS toolkit. Clone the repo, install dependencies, build port ROMs, and integrate with OpenCode workflows — including full Git/GitHub agent supervision.

## Repository

https://github.com/kutasekkoziolka/BrinaOS

This repo lives at `/root/.buddy/work/BrinaOS` when cloned locally.

Remote: `git@github.com:kutasekkoziolka/BrinaOS.git` (SSH)

## What it does

BrinaOS is a "Short n' Sweet" toolkit for porting ColorOS and Realme UI to Snapdragon 865 (SM8250), 870, and 888 (SM8350) devices.

Key scripts:
- `./willpower.sh` — one-time dependency setup (run first, needs sudo)
- `./brina.sh [--Brina] <BASEROM.zip> <PORTROM.zip> [PORTROM2.zip] [PARTITIONS]` — the main porting script, produces a flashable zip in `out/`
- `./caffeine.sh` — helper library (logging, patching functions) sourced by `brina.sh`

## Setup (run once)

```bash
cd /root/.buddy/work/BrinaOS
./willpower.sh
```

This installs every dependency needed to build. Requires sudo on Linux.

## Git / GitHub agent connection

So an agent (e.g. Buddy/OpenCode) can clone, commit, push and supervise this repo on GitHub:

### 1. Add the agent's SSH key to GitHub

The agent's public key is at `/root/.ssh/id_ed25519.pub`.

Copy its contents and add it on GitHub:
- https://github.com/settings/keys → "New SSH key"
- Title: `buddy-opencode` (or any name)
- Key: paste the full `ssh-ed25519 ...` line

### 2. Verify SSH works

```bash
ssh -T git@github.com
```

Should respond: `Hi kutasekkoziolka! You've successfully authenticated...`

### 3. Clone or update the repo

```bash
cd /root/.buddy/work
git clone git@github.com:kutasekkoziolka/BrinaOS.git
cd BrinaOS

# If already cloned, pull latest:
git pull origin main
```

### 4. Make changes, commit and push (agent workflow)

```bash
cd /root/.buddy/work/BrinaOS

# Check status
git status

# Stage changes
git add SKILL.md
# (or: git add .)

# Commit
git commit -m "feat: update BrinaOS skill with GitHub agent instructions"

# Push to GitHub
git push origin main
```

### 5. Supervise / monitor the repo

```bash
# See what changed remotely
git fetch origin
git log --oneline HEAD..origin/main

# See local vs remote diff
git diff HEAD origin/main

# Pull latest changes
git pull origin main
```

## Build a port ROM

```bash
cd /root/.buddy/work/BrinaOS

# Minimal port (keep port ROM's own branding)
./brina.sh <BASEROM.zip> <PORTROM.zip>

# Full BrinaOS look (wordmark, OTA card, setup wizard)
./brina.sh --Brina <BASEROM.zip> <PORTROM.zip>

# With a second port ROM and custom partitions
./brina.sh <BASEROM.zip> <PORTROM.zip> <PORTROM2.zip> system vendor odm
```

Arguments can be local file paths or download URLs — `brina.sh` will fetch URLs automatically.

The finished flashable zip lands in `out/`.

## Supported hardware

| Chipset | Verified devices |
|---------|------------------|
| Snapdragon 865 / 870 | OnePlus 8 Series, OnePlus 9R, OPPO Find X3 |
| Snapdragon 888 | OnePlus 9 Series (9 Pro tested), OPPO Find X3 Pro |

## Tested ROMs

**Base firmware:**
- OnePlus 8 / 8T / 8 Pro: `KB2003_14.0.0.600`, `IN2013_13.1.190`, `IN2023_13.1.0.190`
- OnePlus 9 Pro: `LE2123_14.0.0.1902`

**Target port ROMs:**
- ColorOS 16: OnePlus 15T (`16.0.5.703`), Find X9 Ultra (`16.0.5.702`)
- OxygenOS 16: OnePlus 15 (`16.0.7.201`)
- Realme UI 7: Realme GT 8 Pro (`16.0.5.704`)

## OpenCode integration

Use this skill when the user wants to:
- Clone or update the BrinaOS repository from GitHub
- Install build dependencies (`willpower.sh`)
- Connect an agent to GitHub (SSH key, commit, push, supervise)
- Port a ColorOS / Realme UI ROM to a supported Snapdragon device
- Locate or flash the output zip from `out/`

Example agent prompt:

```
You are helping the user port a ColorOS ROM with BrinaOS.
1. Ensure /root/.buddy/work/BrinaOS exists and is up to date (git pull origin main).
2. Run ./willpower.sh if dependencies are missing.
3. Run ./brina.sh with the provided base and port ROM zips.
4. Commit and push any changes to SKILL.md or scripts: git add . && git commit -m "..." && git push origin main.
5. Report the path to the produced flashable zip in out/.
```

> ⚠️ Porting ROMs can brick a device. Always back up data before flashing. Read the repo docs before starting.
