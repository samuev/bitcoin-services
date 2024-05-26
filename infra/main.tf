
# Configure the Azure provider
provider "azurerm" {
  features {}
}
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.101.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13.1"
    }
  }
}

# Configure the Terraform backend
terraform {
  backend "azurerm" {
    resource_group_name  = var.resource_group_name
    storage_account_name = var.storage_account_name
    container_name       = var.container_name
    key                  = var.key
  }
}

data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
}

#Create a resource group
resource "azurerm_resource_group" "aztfrg" {
 count    = data.azurerm_resource_group.existing.id == null ? 1 : 0 
 name     = var.resource_group_name
 location = var.location
}

# Create an AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name
  
  private_cluster_enabled   = false
  sku_tier = "Free"
  
  default_node_pool {
    name                = "general"
    node_count          = 1
	  min_count           = 1
    max_count           = 10
    vm_size             = "Standard_DS2_v2"
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
  }

   identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "kubenet" 
  }
}
# Create an AKS cluster
#module "aks" {
#  source  = "Azure/aks/azurerm"
#  version = "4.3.0"
#  resource_group_name = azurerm_resource_group.aztfrg.name
#  }

# Configure the Kubernetes provider
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

# Configure the Helm provider
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
  }
}

# Deploy the NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "default"

  values = [
    <<EOF
controller:
  ingressClassResource:
    enabled: true
    name: "nginx-ingress"
EOF
  ]
}

# Deploy a Helm chart
# resource "helm_release" "external_nginx" {
#   name       = "external-nginx"
#   repository = "https://kubernetes.github.io/ingress-nginx"
#   chart      = "ingress-nginx"
#   namespace  = "ingress"
#   create_namespace = true
#   version    = ">= 4.8.0"

#  values = [file("${path.module}/values/ingress.yaml")]
#}

# Create an Ingress rule for the btc-app-eur service
# resource "kubernetes_ingress" "btc_app_eur_ingress" {
#   metadata {
#     name = "btc-app-eur-ingress"
#   }
#   spec {
#     rule {
#       host = "btc-app-eur.service.com"
#       http {
#         path {
#           backend {
#             service_name = kubernetes_service.btc_app_eur_service.metadata[0].name
#             service_port = 81
#           }
#           path = "/"
#         }
#       }
#     }
#   }
#  depends_on = [helm_release.external_nginx]
#}

# Create an Ingress rule for the btc-app-usdt service
resource "kubernetes_manifest" "btc_app_usdt_ingress" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name = "btc-app-usdt-ingress"
      namespace = "default"
    }
    spec = {
      rules = [{
        http = {
          paths = [
            {
              path     = "/usdt"
              pathType = "Prefix"
              backend = {
                service = {
                  name = kubernetes_service.btc_app_usdt_service.metadata[0].name
                  port = {
                    number = 80
                  }
                }
              }
            },
            {
              path     = "/average"
              pathType = "Prefix"
              backend = {
                service = {
                  name = kubernetes_service.btc_app_usdt_service.metadata[0].name
                  port = {
                    number = 80
                  }
                }
              }
            }
          ]
        }
      }]
    }
  }
  depends_on = [helm_release.nginx_ingress]
}

# Deploy applications
resource "kubernetes_deployment" "btc_app_eur" {
  metadata {
    name = "btc-app-eur"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "btc-app-eur"
      }
    }
    template {
      metadata {
        labels = {
          app = "btc-app-eur"
        }
      }
      spec {
        container {
          name  = "btc-app-eur"
          image = "samuev/fetching-btc-prices:eur-latest"
          port {
            container_port = 5001
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "btc_app_usdt" {
  metadata {
    name = "btc-app-usdt"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "btc-app-usdt"
      }
    }
    template {
      metadata {
        labels = {
          app = "btc-app-usdt"
        }
      }
      spec {
        container {
          name  = "btc-app-usdt"
          image = "samuev/fetching-btc-prices:usdt-latest"
          port {
            container_port = 5000
          }
        }
      }
    }
  }
}

# Create services for applications
# resource "kubernetes_service" "btc_app_eur_service" {
#   metadata {
#     name = "btc-app-eur"
#   }
#   spec {
#     selector = {
#       app = "btc-app-eur"
#     }
#     port {
#       port        = 81
#       target_port = 5001
#     }
#     type = "LoadBalancer"
#   }
# }

resource "kubernetes_service" "btc_app_usdt_service" {
  metadata {
    name = "btc-app-usdt"
  }
  spec {
    selector = {
      app = "btc-app-usdt"
    }
    port {
      port        = 80
      target_port = 5000
    }
    type = "LoadBalancer"
  }
}