# remote-env

This is my automation for provisioning remote resources I use for development or for my personal stuff.

## GitHub runner

### Create registration token for a repo

Change directory to the repo and then run: (or replace `{owner}/{repo}`)

```sh
gh api -p everest -X POST repos/{owner}/{repo}/actions/runners/registration-token | jq .token
```

### Create registration token for an org

Change directory to a repo of the org and then run: (or replace `{owner}`)

```sh
gh api -p everest -X POST orgs/{owner}/actions/runners/registration-token | jq .token
```
