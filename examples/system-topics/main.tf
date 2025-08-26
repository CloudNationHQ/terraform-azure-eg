module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.24"

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

module "servicebus" {
  source  = "cloudnationhq/sb/azure"
  version = "~> 2.0"

  naming = local.naming

  config = {
    name                = module.naming.servicebus_namespace.name_unique
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location

    queues = {
      storage_events = {
        enable_partitioning = true
      }
    }
  }
}

module "storage" {
  source  = "cloudnationhq/sa/azure"
  version = "~> 4.0"

  naming = local.naming

  storage = {
    name                = module.naming.storage_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    blob_properties = {
      versioning_enabled       = true
      last_access_time_enabled = true
      change_feed_enabled      = true

      containers = {
        uploads = {
          metadata = {
            project    = "marketing"
            owner      = "marketing team"
            department = "digital"
            costcenter = "mkt-001"
            compliance = "gdpr"
          }
        }
      }
    }
  }
}

module "eventgrid" {
  source  = "cloudnationhq/eg/azure"
  version = "~> 2.0"

  naming = local.naming

  config = {
    name                = module.naming.eventgrid_domain.name
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location

    system_topics = {
      storage = {
        source_resource_id = module.storage.account.id
        topic_type         = "Microsoft.Storage.StorageAccounts"

        event_subscriptions = local.event_subscriptions
      }
    }
  }
}
