terraform {
  required_version = ">= 1.5"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.100"
    }
  }
}

# cloud_id, folder_id and token come from YC_CLOUD_ID, YC_FOLDER_ID, YC_TOKEN (see env.sh)
provider "yandex" {
  zone = var.zones[0]
}
