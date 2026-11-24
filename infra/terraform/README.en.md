# infra/terraform

Two Ubuntu 24.04 virtual machines in Yandex Cloud, in different availability zones: a dedicated network, one subnet per zone and a security group (SSH and application port 8000), and notes-api started automatically on every VM. Русская версия: [README.md](README.md).

## Contents

| File | Purpose |
| --- | --- |
| `versions.tf` | Terraform and provider versions, provider settings |
| `variables.tf` | inputs: zones, VM size, SSH key, allowed addresses |
| `main.tf` | network, subnets, security group, VMs |
| `outputs.tf` | public IPs, SSH commands and `/health` URLs |
| `cloud-init.yaml.tftpl` | first boot: Docker, registry login, notes-api start |
| `env.sh` | short-lived credentials of the `terraform-sa` service account |
| `.terraform.lock.hcl` | exact provider versions and checksums (committed) |

## Decisions

- Access goes through the `terraform-sa` service account with the `editor` role on a dedicated `portfolio` folder. The token is short-lived (up to 12 hours); no keys are stored on disk.
- The `portfolio` folder is separate from coursework resources, so `terraform destroy` cannot touch anything else.
- State is stored in the `tfstate-ilembet-portfolio` Object Storage bucket with versioning. The bucket access key lives outside the repository in `~/.config/portfolio/s3.env` and is loaded by `env.sh`.
- notes-api starts on every VM at first boot via cloud-init. Images come from the `portfolio` Yandex Container Registry: the `ru-central1-d` zone cannot reach Docker Hub or GHCR, while the Yandex registry is reachable over the cloud's internal network. The VM logs in to the registry with a short-lived token of its `vm-puller` service account, which may only pull images. The database password is generated on the VM and never passes through Terraform.
- The registry, the state bucket and the service accounts were created once with `yc` and are not part of this stack, so `terraform destroy` does not remove them.
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

Check the app (3–5 minutes after `apply`): `terraform output health_urls`.

Remove everything after a session to avoid charges:

```bash
terraform destroy
```

## Next

State locking with YDB, modules, configuring the VMs with Ansible instead of cloud-init.
