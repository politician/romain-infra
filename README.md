# Romain's infra

Manages overarching cloud resources for my personal usage.

> This repo is part of my journey to use git as the source of truth for everything I can automate.

## Projects

### Romain's infrastructure

This repo.

### Barissat's infrastructure

[Repo](https://github.com/politician/barissat-infra) to manage cloud resources for my family usage.

### Domain names manager

My domain names configuration is in a private repo and is automatically synced to the various domain providers using GitHub Actions.

However, several providers require for requests to come from a fixed IP address which is why I decided to use a hosted Github Runner on Digital Ocean.

## Cloud providers

### AWS

To access sub-accounts via the AWS console, login to AWS as the global user and switch role.

Global user credentials:

- Sign-in URL: `terraform output --raw global_aws_signin_url`
- Username: `terraform output --raw global_aws_user_name`
- Password: `terraform output --raw global_aws_user_password | base64 --decode | gpg --decrypt`

Switch role information:

- Account: Copy the desired sub-account ID from [the organization page](https://us-east-1.console.aws.amazon.com/organizations/v2/home/accounts)
- Role: `OrganizationAccountAccessRole`

### Google KMS

In order to sign/verify/encrypt stuff across various projects, I use Google KMS.

## Forking

If you want to fork this repo and modify it for your own personal/commercial usage, please do so freely, it is licensed accordingly (Apache 2.0).

## First-time setup

The way to set it up for the first time is:

1. Rename the project `romain-infra` to your liking, this is the main project (this repo).
2. Remove the other projects
3. Login to the various cloud providers or set environment variables accordingly (most likely as root/admin user)
4. Run `terraform init`
5. If you forked the repo, rename it accordingly and then import it with (replace `romain-infra` accordingly):

    ```sh
    terraform import module.romain-infra.github_repository.github[\"main\"] romain-infra
    ```

6. Run `terraform apply`
7. This will create the main project and some global credentials for clouds that support it (AWS/GCP), and set them up in Terraform Cloud.
8. Upload the state to Terraform Cloud:

    1. Uncomment the lines in `_backend.tf` and modify accordingly
    2. Run `terraform init`
    3. Answer that you want to copy the state in the prompt

9. Commit and push your work.
10. The plan in Terraform Cloud should run smoothly and display that no changes were detected.

## Ongoing changes

Make modifications/add your projects through pull requests if you want to get speculative plans before merging.

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
