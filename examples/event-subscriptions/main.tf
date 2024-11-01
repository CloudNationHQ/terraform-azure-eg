module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "storage" {
  source  = "cloudnationhq/sa/azure"
  version = "~> 2.0"

  naming = local.naming

  storage = {
    name           = module.naming.storage_account.name_unique
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name

    blob_properties = {
      versioning_enabled       = true
      last_access_time_enabled = true
      change_feed_enabled      = true

      containers = {
        uploads = {
          name = "uploads"
          metadata = {
            department = "marketing"
            project    = "content"
          }
        }
      }
    }
  }
}

module "servicebus" {
  source  = "cloudnationhq/sb/azure"
  version = "~> 1.0"

  naming = local.naming

  config = {
    name           = module.naming.servicebus_namespace.name_unique
    resource_group = module.rg.groups.demo.name
    location       = module.rg.groups.demo.location

    queues = {
      storage = {
        name                = "storage-events"
        enable_partitioning = true
        max_delivery_count  = 10
      }
    }
  }
}

module "eventgrid" {
  #source  = "cloudnationhq/eg/azure"
  #version = "~> 1.0"
  source = "../../"

  config = {
    name           = module.naming.eventgrid_domain.name
    resource_group = module.rg.groups.demo.name
    location       = module.rg.groups.demo.location

    event_subsciptions = local.event_subscriptions
  }
}
