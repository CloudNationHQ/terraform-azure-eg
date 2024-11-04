# Event Subscriptions

This deploys event subscriptions

## Types

```hcl
config = object({
  name           = string
  resource_group = string
  location       = string
  event_subscriptions = optional(map(object({
    scope                         = string
    event_delivery_schema        = string
    included_event_types         = list(string)
    service_bus_queue_endpoint_id = string
    subject_filter = optional(object({
      subject_begins_with = string
      case_sensitive      = optional(bool, false)
    }))
    advanced_filter = optional(object({
      number_greater_than = optional(map(number))
      string_in           = optional(map(list(string)))
      string_begins_with  = optional(map(list(string)))
    }))
    retry_policy = optional(object({
      max_delivery_attempts = optional(number, 5)
      event_time_to_live    = optional(number, 1440)
    }))
  })))
})
```
