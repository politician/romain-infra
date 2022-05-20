# Romain's infra

Automation for provisioning overarching cloud resources for my personal usage.

> This repo is part of my journey to use git as the source of truth for everything I can automate.

## Project: Domains

My domain names configuration is in a private repo and is automatically synced to the various domain providers using GitHub Actions.

However, several providers require for requests to come from a fixed IP address which is why I decided to use a hosted Github Runner on DigitalOcean.

## Technical notes

### GitHub runner

#### Create registration token for a repo

Change directory to the repo and then run: (or replace `{owner}/{repo}`)

```sh
gh api -p everest -X POST repos/{owner}/{repo}/actions/runners/registration-token | jq .token
```

#### Create registration token for an org

Change directory to a repo of the org and then run: (or replace `{owner}`)

```sh
gh api -p everest -X POST orgs/{owner}/actions/runners/registration-token | jq .token
```
