locals {
  event_subscriptions = {
    user-notifications = {
      event_delivery_schema = "CloudEventSchemaV1_0"
      included_event_types = [
        "user.signup",
        "user.passwordreset",
        "user.profile.update"
      ]

      service_bus_topic_endpoint_id = module.servicebus.topics.notifications.id

      advanced_filter = {
        string_in = {
          "data.userType" = ["premium", "enterprise"]
        }
        string_not_in = {
          "data.region" = ["internal", "test"]
        }
      }

      delivery_property_mappings = {
        notification-type = {
          header_name  = "X-Notification-Type"
          type         = "Dynamic"
          source_field = "type"
        }
        priority = {
          header_name  = "X-Priority"
          type         = "Dynamic"
          source_field = "data.priority"
        }
        user-tier = {
          header_name  = "X-User-Tier"
          type         = "Dynamic"
          source_field = "data.userType"
        }
      }
    }
  }
}
