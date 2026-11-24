terraform {
  required_version = ">= 1.6.3"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.100"
    }
  }

  # State is stored in Yandex Object Storage.
  # Credentials come from AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY (loaded by env.sh).
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "tfstate-ilembet-portfolio"
    region = "ru-central1"
    key    = "infra/terraform/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

# cloud_id, folder_id and token come from YC_CLOUD_ID, YC_FOLDER_ID, YC_TOKEN (see env.sh)
provider "yandex" {
  zone = var.zones[0]
}
