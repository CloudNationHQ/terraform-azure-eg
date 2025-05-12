# Event Grid

This terraform module streamlines the creation and management of azure event grid resources. It enables a robust event-driven architecture for cloud-native applications with minimal configuration.

## Features

Utilization of terratest for robust validation.

Supports creation of multiple event grid domains, system topic and custom topics.

Supports event subscriptions with multiple endpoint types like servicebus, eventhub and webhooks.

Enabled advanced filtering through subject and property based rules.

Supports multiple delivery property configurations per event subscription.

Allows custom retry policies and event time to live settings.

Facilitates event routing through header mappings

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 4.0)

## Resources

The following resources are used by this module:

- [azurerm_eventgrid_domain.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_domain) (resource)
- [azurerm_eventgrid_domain_topic.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_domain_topic) (resource)
- [azurerm_eventgrid_event_subscription.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_event_subscription) (resource)
- [azurerm_eventgrid_system_topic.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_system_topic) (resource)
- [azurerm_eventgrid_system_topic_event_subscription.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_system_topic_event_subscription) (resource)
- [azurerm_eventgrid_topic.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_topic) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_config"></a> [config](#input\_config)

Description: Contains all eventgrid configuration

Type:

```hcl
object({
    resource_group_name = optional(string, null)
    location            = optional(string, null)
    tags                = optional(map(string))
    domains = optional(map(object({
      name = optional(string, null)
      domain_topics = optional(map(object({
        name = optional(string, null)
        event_subscriptions = optional(map(object({
          name                                 = optional(string, null)
          event_delivery_schema                = optional(string, null)
          included_event_types                 = optional(list(string), null)
          labels                               = optional(list(string), null)
          hybrid_connection_endpoint_id        = optional(string, null)
          advanced_filtering_on_arrays_enabled = optional(bool, false)
          expiration_time_utc                  = optional(string, null)
          service_bus_queue_endpoint_id        = optional(string, null)
          service_bus_topic_endpoint_id        = optional(string, null)
          eventhub_endpoint_id                 = optional(string, null)
          endpoint_type                        = optional(string, null)
          endpoint_id                          = optional(string, null)
          azure_function_endpoint = optional(object({
            function_id                       = string
            max_events_per_batch              = optional(number, null)
            preferred_batch_size_in_kilobytes = optional(number, null)
          }), null)
          webhook_endpoint = optional(object({
            url                               = string
            preferred_batch_size_in_kilobytes = optional(number, null)
            max_events_per_batch              = optional(number, null)
            active_directory_tenant_id        = optional(string, null)
            active_directory_app_id_or_uri    = optional(string, null)
          }), null)
          retry_policy = optional(object({
            max_delivery_attempts = number
            event_time_to_live    = number
          }), null)
          subject_filter = optional(object({
            subject_begins_with = optional(string, "/")
            subject_ends_with   = optional(string, null)
            case_sensitive      = optional(bool, false)
          }), null)
          filters = optional(object({
            subject_begins_with = optional(string, "/")
            subject_ends_with   = optional(string, null)
            case_sensitive      = optional(bool, false)
          }), null)
          advanced_filter = optional(object({
            bool_equals                   = optional(map(bool), {})
            is_not_null                   = optional(map(string), {})
            is_null_or_undefined          = optional(map(string), {})
            number_greater_than           = optional(map(number), {})
            number_greater_than_or_equals = optional(map(number), {})
            number_less_than              = optional(map(number), {})
            number_less_than_or_equals    = optional(map(number), {})
            number_in                     = optional(map(list(number)), {})
            number_not_in                 = optional(map(list(number)), {})
            string_begins_with            = optional(map(list(string)), {})
            string_ends_with              = optional(map(list(string)), {})
            string_contains               = optional(map(list(string)), {})
            string_in                     = optional(map(list(string)), {})
            string_not_ends_with          = optional(map(list(string)), {})
            string_not_in                 = optional(map(list(string)), {})
          }), null)
          delivery_property_mappings = optional(map(object({
            header_name  = string
            type         = string
            value        = optional(string, null)
            source_field = optional(string, null)
            secret       = optional(string, null)
          })), {})
        })), {})
      })), {})
    })), {})
    custom_topics = optional(map(object({
      name                          = optional(string, null)
      input_schema                  = optional(string, "EventGridSchema")
      public_network_access_enabled = optional(bool, true)
      local_auth_enabled            = optional(bool, false)
      inbound_ip_rule               = optional(any, null)
      input_mapping_fields = optional(object({
        id           = optional(string, null)
        topic        = optional(string, null)
        subject      = optional(string, null)
        event_time   = optional(string, null)
        event_type   = optional(string, null)
        data_version = optional(string, null)
      }), null)
      input_mapping_default_values = optional(object({
        data_version = optional(string, null)
        event_type   = optional(string, null)
        subject      = optional(string, null)
      }), null)
      event_subscriptions = optional(map(object({
        name                                 = optional(string, null)
        event_delivery_schema                = optional(string, null)
        included_event_types                 = optional(list(string), null)
        labels                               = optional(list(string), null)
        hybrid_connection_endpoint_id        = optional(string, null)
        advanced_filtering_on_arrays_enabled = optional(bool, false)
        expiration_time_utc                  = optional(string, null)
        service_bus_queue_endpoint_id        = optional(string, null)
        service_bus_topic_endpoint_id        = optional(string, null)
        eventhub_endpoint_id                 = optional(string, null)
        endpoint_type                        = optional(string, null)
        endpoint_id                          = optional(string, null)
        azure_function_endpoint = optional(object({
          function_id                       = string
          max_events_per_batch              = optional(number, null)
          preferred_batch_size_in_kilobytes = optional(number, null)
        }), null)
        webhook_endpoint = optional(object({
          url                               = string
          preferred_batch_size_in_kilobytes = optional(number, null)
          max_events_per_batch              = optional(number, null)
          active_directory_tenant_id        = optional(string, null)
          active_directory_app_id_or_uri    = optional(string, null)
        }), null)
        retry_policy = optional(object({
          max_delivery_attempts = number
          event_time_to_live    = number
        }), null)
        subject_filter = optional(object({
          subject_begins_with = optional(string, "/")
          subject_ends_with   = optional(string, null)
          case_sensitive      = optional(bool, false)
        }), null)
        filters = optional(object({
          subject_begins_with = optional(string, "/")
          subject_ends_with   = optional(string, null)
          case_sensitive      = optional(bool, false)
        }), null)
        advanced_filter = optional(object({
          bool_equals                   = optional(map(bool), {})
          is_not_null                   = optional(map(string), {})
          is_null_or_undefined          = optional(map(string), {})
          number_greater_than           = optional(map(number), {})
          number_greater_than_or_equals = optional(map(number), {})
          number_less_than              = optional(map(number), {})
          number_less_than_or_equals    = optional(map(number), {})
          number_in                     = optional(map(list(number)), {})
          number_not_in                 = optional(map(list(number)), {})
          string_begins_with            = optional(map(list(string)), {})
          string_ends_with              = optional(map(list(string)), {})
          string_contains               = optional(map(list(string)), {})
          string_in                     = optional(map(list(string)), {})
          string_not_ends_with          = optional(map(list(string)), {})
          string_not_in                 = optional(map(list(string)), {})
        }), null)
        delivery_property_mappings = optional(map(object({
          header_name  = string
          type         = string
          value        = optional(string, null)
          source_field = optional(string, null)
          secret       = optional(string, null)
        })), {})
      })), {})
    })), {})
    system_topics = optional(map(object({
      name                   = optional(string, null)
      source_arm_resource_id = string
      topic_type             = string
      event_subscriptions = optional(map(object({
        included_event_types                 = optional(list(string), [])
        event_delivery_schema                = optional(string, null)
        service_bus_queue_endpoint_id        = optional(string, null)
        service_bus_topic_endpoint_id        = optional(string, null)
        eventhub_endpoint_id                 = optional(string, null)
        labels                               = optional(list(string), [])
        expiration_time_utc                  = optional(string, null)
        advanced_filtering_on_arrays_enabled = optional(bool, false)
        hybrid_connection_endpoint_id        = optional(string, null)
        storage_blob_dead_letter_destination = optional(object({
          storage_account_id          = string
          storage_blob_container_name = string
        }), null)
        storage_queue_endpoint = optional(object({
          storage_account_id                    = string
          queue_name                            = string
          queue_message_time_to_live_in_seconds = optional(number, null)
        }), null)
        delivery_identity = optional(object({
          type                   = string
          user_assigned_identity = optional(string, null)
        }), null)
        dead_letter_identity = optional(object({
          type                   = string
          user_assigned_identity = optional(string, null)
        }), null)
        azure_function_endpoint = optional(object({
          function_id                       = string
          max_events_per_batch              = optional(number, null)
          preferred_batch_size_in_kilobytes = optional(number, null)
        }), null)
        webhook_endpoint = optional(object({
          url                               = string
          preferred_batch_size_in_kilobytes = optional(number, null)
          max_events_per_batch              = optional(number, null)
          active_directory_app_id_or_uri    = optional(string, null)
          active_directory_tenant_id        = optional(string, null)
        }), null)
        subject_filter = optional(object({
          subject_begins_with = optional(string, "/")
          subject_ends_with   = optional(string, null)
          case_sensitive      = optional(bool, false)
        }), null)
        retry_policy = optional(object({
          max_delivery_attempts = number
          event_time_to_live    = number
        }), null)
        delivery_property_mappings = optional(map(object({
          header_name  = string
          type         = string
          value        = optional(string, null)
          source_field = optional(string, null)
          secret       = optional(string, null)
        })), null)
        advanced_filter = optional(object({
          bool_equals                   = optional(map(bool), {})
          is_not_null                   = optional(map(string), {})
          is_null_or_undefined          = optional(map(string), {})
          number_greater_than           = optional(map(number), {})
          number_greater_than_or_equals = optional(map(number), {})
          number_less_than              = optional(map(number), {})
          number_less_than_or_equals    = optional(map(number), {})
          number_in                     = optional(map(list(number)), {})
          number_not_in                 = optional(map(list(number)), {})
          string_begins_with            = optional(map(list(string)), {})
          string_ends_with              = optional(map(list(string)), {})
          string_contains               = optional(map(list(string)), {})
          string_in                     = optional(map(list(string)), {})
          string_not_ends_with          = optional(map(list(string)), {})
          string_not_in                 = optional(map(list(string)), {})
        }), null)
      })), {})
    })), {})
    event_subscriptions = optional(map(object({
      name                                 = optional(string, null)
      scope                                = string
      event_delivery_schema                = optional(string, null)
      included_event_types                 = optional(list(string), null)
      labels                               = optional(list(string), null)
      hybrid_connection_endpoint_id        = optional(string, null)
      advanced_filtering_on_arrays_enabled = optional(bool, false)
      expiration_time_utc                  = optional(string, null)
      service_bus_queue_endpoint_id        = optional(string, null)
      service_bus_topic_endpoint_id        = optional(string, null)
      eventhub_endpoint_id                 = optional(string, null)
      endpoint_type                        = optional(string, null)
      endpoint_id                          = optional(string, null)
      azure_function_endpoint = optional(object({
        function_id                       = string
        max_events_per_batch              = optional(number, null)
        preferred_batch_size_in_kilobytes = optional(number, null)
      }), null)
      webhook_endpoint = optional(object({
        url                               = string
        preferred_batch_size_in_kilobytes = optional(number, null)
        max_events_per_batch              = optional(number, null)
        active_directory_tenant_id        = optional(string, null)
        active_directory_app_id_or_uri    = optional(string, null)
      }), null)
      retry_policy = optional(object({
        max_delivery_attempts = number
        event_time_to_live    = number
      }), null)
      subject_filter = optional(object({
        subject_begins_with = optional(string, "/")
        subject_ends_with   = optional(string, null)
        case_sensitive      = optional(bool, false)
      }), null)
      filters = optional(object({
        subject_begins_with = optional(string, "/")
        subject_ends_with   = optional(string, null)
        case_sensitive      = optional(bool, false)
      }), null)
      advanced_filter = optional(object({
        bool_equals                   = optional(map(bool), {})
        is_not_null                   = optional(map(string), {})
        is_null_or_undefined          = optional(map(string), {})
        number_greater_than           = optional(map(number), {})
        number_greater_than_or_equals = optional(map(number), {})
        number_less_than              = optional(map(number), {})
        number_less_than_or_equals    = optional(map(number), {})
        number_in                     = optional(map(list(number)), {})
        number_not_in                 = optional(map(list(number)), {})
        string_begins_with            = optional(map(list(string)), {})
        string_ends_with              = optional(map(list(string)), {})
        string_contains               = optional(map(list(string)), {})
        string_in                     = optional(map(list(string)), {})
        string_not_ends_with          = optional(map(list(string)), {})
        string_not_in                 = optional(map(list(string)), {})
      }), null)
      delivery_property_mappings = optional(map(object({
        header_name  = string
        type         = string
        value        = optional(string, null)
        source_field = optional(string, null)
        secret       = optional(string, null)
      })), {})
    })), {})
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: default azure region to be used.

Type: `string`

Default: `null`

### <a name="input_naming"></a> [naming](#input\_naming)

Description: contains naming convention

Type: `map(string)`

Default: `{}`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: default resource group to be used.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_custom_topics"></a> [custom\_topics](#output\_custom\_topics)

Description: contains custom topics configuration

### <a name="output_domain_topics"></a> [domain\_topics](#output\_domain\_topics)

Description: contains domain topics configuration

### <a name="output_domains"></a> [domains](#output\_domains)

Description: contains eventgrid domains configuration

### <a name="output_event_subscriptions"></a> [event\_subscriptions](#output\_event\_subscriptions)

Description: contains event subscriptions configuration

### <a name="output_system_topic_event_subscriptions"></a> [system\_topic\_event\_subscriptions](#output\_system\_topic\_event\_subscriptions)

Description: contains system topic event subscriptions configuration

### <a name="output_system_topics"></a> [system\_topics](#output\_system\_topics)

Description: contains system topics configuration
<!-- END_TF_DOCS -->

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Authors

Module is maintained by [these awesome contributors](https://github.com/cloudnationhq/terraform-azure-eg/graphs/contributors).

## Contributing

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md).

## License

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/event-grid/)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/eventgrid/)
- [Rest Api Specs](https://github.com/hashicorp/pandora/tree/main/api-definitions/resource-manager/EventGrid)
