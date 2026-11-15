# infra/terraform

Two Ubuntu 24.04 virtual machines in Yandex Cloud, in different availability zones: a dedicated network, one subnet per zone and a security group (SSH and application port 8000). Русская версия: [README.md](README.md).

## Contents

| File | Purpose |
| --- | --- |
| `versions.tf` | Terraform and provider versions, provider settings |
| `variables.tf` | inputs: zones, VM size, SSH key, allowed addresses |
| `main.tf` | network, subnets, security group, VMs |
| `outputs.tf` | public IPs and ready-to-use SSH commands |
| `env.sh` | short-lived credentials of the `terraform-sa` service account |
| `.terraform.lock.hcl` | exact provider versions and checksums (committed) |

## Decisions

- Access goes through the `terraform-sa` service account with the `editor` role on a dedicated `portfolio` folder. The token is short-lived (up to 12 hours); no keys are stored on disk.
- The `portfolio` folder is separate from coursework resources, so `terraform destroy` cannot touch anything else.
- VMs are preemptible, 20% vCPU, HDD: the lowest cost for a lab environment.
- One VM per zone listed in `zones`: adding a zone means adding one line.

## Usage

Requires `yc` (profile set to the `portfolio` folder), Terraform and the provider mirror in `~/.terraformrc`.

```bash
cd infra/terraform
source env.sh
cp terraform.tfvars.example terraform.tfvars   # optional
terraform init
terraform plan
terraform apply
```

Connect: `terraform output ssh_commands`.

Remove everything after a session to avoid charges:

```bash
terraform destroy
```

## Next

Remote state in Object Storage, modules, deploying notes-api to the VMs with Ansible.
