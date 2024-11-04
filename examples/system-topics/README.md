# System Topics

This deploys system topic and event subscriptions

## Types

```hcl
config = object({
  name           = string
  resource_group = string
  location       = string
  system_topics = optional(map(object({
    source_arm_resource_id = string
    topic_type            = string
    event_subscriptions = optional(map(object({
      event_delivery_schema = optional(string)
      included_event_types  = optional(list(string))
      service_bus_queue_endpoint_id = optional(string)
      subject_filter = optional(object({
        subject_begins_with = optional(string)
        case_sensitive      = optional(bool)
      }))
      retry_policy = optional(object({
        max_delivery_attempts = optional(number)
        event_time_to_live   = optional(number)
      }))
      delivery_property_mappings = optional(map(object({
        header_name  = string
        type         = string
        source_field = optional(string)
        value       = optional(string)
      })))
    })))
  })))
})
```
