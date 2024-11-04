# Domain Topics

This deploys domain topics and event subscriptions

## Types

```hcl
config = object({
  name           = string
  resource_group = string
  location       = string
  domains = optional(map(object({
    domain_topics = optional(map(object({
      event_subscriptions = optional(map(object({
        event_delivery_schema         = string
        included_event_types          = list(string)
        service_bus_queue_endpoint_id = string
        labels                        = optional(list(string))
        retry_policy = optional(object({
          max_delivery_attempts = optional(number, 5)
          event_time_to_live    = optional(number, 1440)
        }))
        subject_filter = optional(object({
          subject_begins_with = string
          case_sensitive      = optional(bool, false)
        }))
        delivery_property_mappings = optional(map(object({
          header_name  = string
          type         = string
          value       = optional(string)
          source_field = optional(string)
        })))
      })))
    })))
  })))
})
```
