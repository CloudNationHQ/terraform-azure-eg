module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.32"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 3.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "servicebus" {
  source  = "cloudnationhq/sb/azure"
  version = "~> 3.0"

  servicebus_namespace = {
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
  version = "~> 5.0"

  storage = {
    name                = module.naming.storage_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    blob_properties = {
      containers = {
        uploads = {}
      }
    }
  }
}

# system topic owned by another workload, typically living in a separate state file
module "platform" {
  source  = "cloudnationhq/eg/azure"
  version = "~> 3.0"

  eventgrid = {
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location

    system_topics = {
      storage = {
        name               = module.naming.eventgrid_topic.name_unique
        source_resource_id = module.storage.account.id
        topic_type         = "Microsoft.Storage.StorageAccounts"
      }
    }
  }
}

# event subscriptions attached to the existing system topic
module "eventgrid" {
  source  = "cloudnationhq/eg/azure"
  version = "~> 3.0"

  eventgrid = {
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location

    system_topics = {
      storage = {
        use_existing_topic  = true
        name                = module.platform.system_topics.storage.name
        resource_group_name = module.platform.system_topics.storage.resource_group_name

        event_subscriptions = local.event_subscriptions
      }
    }
  }
}
