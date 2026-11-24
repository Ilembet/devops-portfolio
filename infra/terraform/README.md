# infra/terraform

Две виртуальные машины Ubuntu 24.04 в Yandex Cloud, в разных зонах доступности: своя сеть, подсеть в каждой зоне, группа безопасности (SSH и порт приложения 8000) и автоматический запуск notes-api на каждой ВМ. English version: [README.en.md](README.en.md).

## Что внутри

| Файл | Назначение |
| --- | --- |
| `versions.tf` | версия Terraform и провайдера, настройки провайдера |
| `variables.tf` | параметры: зоны, размер ВМ, ключ SSH, разрешённые адреса |
| `main.tf` | сеть, подсети, группа безопасности, ВМ |
| `outputs.tf` | публичные IP, команды SSH и адреса проверки `/health` |
| `cloud-init.yaml.tftpl` | первый запуск ВМ: Docker, вход в реестр, запуск notes-api |
| `env.sh` | временные учётные данные сервисного аккаунта `terraform-sa` |
| `.terraform.lock.hcl` | точные версии и контрольные суммы провайдера (в git) |

## Решения

- Доступ через сервисный аккаунт `terraform-sa` с ролью `editor` на отдельный каталог `portfolio`. Токен временный (до 12 часов), ключи на диске не хранятся.
- Каталог `portfolio` отделён от учебных ресурсов: `terraform destroy` не заденет ничего лишнего.
- Состояние хранится в бакете Object Storage `tfstate-ilembet-portfolio` с версионированием. Ключ доступа к бакету лежит вне репозитория, в `~/.config/portfolio/s3.env`, и подгружается `env.sh`.
- notes-api запускается на ВМ при первой загрузке через cloud-init. Образы берутся из Yandex Container Registry `portfolio`: из зоны `ru-central1-d` нет доступа к Docker Hub и GHCR, а реестр Yandex доступен по внутренней сети облака. ВМ входит в реестр временным токеном своего сервисного аккаунта `vm-puller`, у которого есть только право скачивать образы. Пароль базы генерируется на ВМ и в Terraform не попадает.
- Реестр, бакет состояния и сервисные аккаунты созданы один раз командами `yc` и не входят в этот стек, поэтому `terraform destroy` их не удаляет.
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

Проверка приложения (через 3–5 минут после `apply`): `terraform output health_urls`.

Удалить всё после занятия, чтобы не платить:

```bash
terraform destroy
```

## Дальше

Блокировка состояния через YDB, модули, настройка ВМ через Ansible вместо cloud-init.
