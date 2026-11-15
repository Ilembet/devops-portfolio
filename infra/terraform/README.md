# infra/terraform

Две виртуальные машины Ubuntu 24.04 в Yandex Cloud, в разных зонах доступности: своя сеть, подсеть в каждой зоне, группа безопасности (SSH и порт приложения 8000). English version: [README.en.md](README.en.md).

## Что внутри

| Файл | Назначение |
| --- | --- |
| `versions.tf` | версия Terraform и провайдера, настройки провайдера |
| `variables.tf` | параметры: зоны, размер ВМ, ключ SSH, разрешённые адреса |
| `main.tf` | сеть, подсети, группа безопасности, ВМ |
| `outputs.tf` | публичные IP и готовые команды SSH |
| `env.sh` | временные учётные данные сервисного аккаунта `terraform-sa` |
| `.terraform.lock.hcl` | точные версии и контрольные суммы провайдера (в git) |

## Решения

- Доступ через сервисный аккаунт `terraform-sa` с ролью `editor` на отдельный каталог `portfolio`. Токен временный (до 12 часов), ключи на диске не хранятся.
- Каталог `portfolio` отделён от учебных ресурсов: `terraform destroy` не заденет ничего лишнего.
- ВМ прерываемые, 20% vCPU, HDD: минимальная стоимость для учебного стенда.
- По одной ВМ в каждой зоне из списка `zones`: добавить зону значит добавить строку.

## Запуск

Нужны `yc` (профиль на каталоге `portfolio`), Terraform и зеркало провайдера в `~/.terraformrc`.

```bash
cd infra/terraform
source env.sh
cp terraform.tfvars.example terraform.tfvars   # по желанию
terraform init
terraform plan
terraform apply
```

Подключение: `terraform output ssh_commands`.

Удалить всё после занятия, чтобы не платить:

```bash
terraform destroy
```

## Дальше

Хранение состояния в Object Storage, модули, установка notes-api на ВМ через Ansible.
