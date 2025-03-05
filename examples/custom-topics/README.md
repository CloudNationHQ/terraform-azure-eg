# Custom Topics

This deploys topics and event subscriptions that fits more specific, custom use cases

## Types

```hcl
config = object({
  resource_group = string
  location       = string
  custom_topics = optional(map(object({
    input_schema = string
    public_network_access_enabled = optional(bool, true)
    event_subscriptions = optional(map(object({
      event_delivery_schema           = string
      included_event_types           = list(string)
      service_bus_topic_endpoint_id  = string
      advanced_filter = optional(object({
        string_in     = optional(map(list(string)))
        string_not_in = optional(map(list(string)))
      }))
      delivery_property_mappings = optional(map(object({
        header_name  = string
        type         = string
        source_field = string
      })))
    })))
  })))
})
```
