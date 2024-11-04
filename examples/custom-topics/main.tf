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

    topics = {
      notifications = {
        name                = "user-notifications"
        enable_partitioning = true
        subscriptions = {
          premium = {
            name               = "premium-users"
            max_delivery_count = 10
            sql_filter         = "userType = 'premium'"
          }
          enterprise = {
            name               = "enterprise-users"
            max_delivery_count = 10
            sql_filter         = "userType = 'enterprise'"
          }
        }
      }
    }
  }
}

module "eventgrid" {
  source  = "cloudnationhq/eg/azure"
  version = "~> 1.0"

  naming = local.naming

  config = {
    name           = module.naming.eventgrid_domain.name
    resource_group = module.rg.groups.demo.name
    location       = module.rg.groups.demo.location

    custom_topics = {
      notifications = {
        input_schema                  = "CloudEventSchemaV1_0"
        public_network_access_enabled = true

        event_subscriptions = local.event_subscriptions
      }
    }
  }
}
