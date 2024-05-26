resource_group_name  = "mybtcResourceGroup"
location             = "eastus"
cluster_name         = "mytfbtcAKScluster"
kubernetes_version   = "1.28.5"
system_node_count    = 1
storage_account_name = "mystatestorageaccount"
container_name       = "tfstate"
key                  = "terraform.tfstate"