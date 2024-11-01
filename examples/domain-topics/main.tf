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

module "servicebus" {
  source  = "cloudnationhq/sb/azure"
  version = "~> 1.0"

  naming = local.naming

  config = {
    name           = module.naming.servicebus_namespace.name_unique
    resource_group = module.rg.groups.demo.name
    location       = module.rg.groups.demo.location

    queues = {
      orders = {
        default_message_ttl                  = "P14D"
        enable_partitioning                  = true
        dead_lettering_on_message_expiration = true
        max_delivery_count                   = 10
        enable_express                       = false
      }
    }

    topics = {
      notifications = {
        enable_partitioning   = true
        enable_express        = false
        max_size_in_megabytes = 5120

        subscriptions = {
          alerts = {
            max_delivery_count                   = 10
            dead_lettering_on_message_expiration = true
            enable_batched_operations            = true
          }
        }
      }
    }
  }
}

module "eventgrid" {
  #source  = "cloudnationhq/eg/azure"
  #version = "~> 0.1"
  source = "../../"

  config = {
    name           = module.naming.eventgrid_domain.name
    resource_group = module.rg.groups.demo.name
    location       = module.rg.groups.demo.location

    domains = {
      primary = {
        domain_topics = {
          orders = {
            event_subscriptions = local.event_subscriptions
          }
        }
      }
    }
  }
}
