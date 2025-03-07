# domains
resource "azurerm_eventgrid_domain" "this" {
  for_each = lookup(
    var.config, "domains", {}
  )

  name = try(
    each.value.name, join("-", [var.naming.eventgrid_domain, each.key])
  )

  resource_group_name = coalesce(lookup(var.config, "resource_group", null), var.resource_group)
  location            = coalesce(lookup(var.config, "location", null), var.location)

  tags = try(
    var.config.tags, var.tags, null
  )
}

# domain topics
resource "azurerm_eventgrid_domain_topic" "this" {
  for_each = merge(flatten([
    for domain_key, domain in lookup(var.config, "domains", {}) : {
      for topic_key, topic in lookup(domain, "domain_topics", {}) :
      "${domain_key}-${topic_key}" => {
        domain_name = azurerm_eventgrid_domain.this[domain_key].name
        domain_key  = domain_key
        name = try(
          topic.name, join("-", [var.naming.eventgrid_domain_topic, topic_key])
        )
      }
    }
  ])...)

  name                = each.value.name
  domain_name         = each.value.domain_name
  resource_group_name = coalesce(lookup(var.config, "resource_group", null), var.resource_group)
}

# subscriptions
resource "azurerm_eventgrid_event_subscription" "this" {
  for_each = merge({
    # domain topic subscriptions
    for item in flatten([
      for domain_key, domain in lookup(var.config, "domains", {}) : [
        for topic_key, topic in lookup(domain, "domain_topics", {}) : [
          for sub_key, sub in lookup(topic, "event_subscriptions", {}) : {
            id           = "${domain_key}-${topic_key}-${sub_key}"
            domain_key   = domain_key
            topic_key    = topic_key
            subscription = sub
            name = try(
              sub.name, join("-", [var.naming.eventgrid_event_subscription, sub_key])
            )
          }
        ]
      ]
      ]) : item.id => {

      name         = item.name
      scope        = azurerm_eventgrid_domain_topic.this["${item.domain_key}-${item.topic_key}"].id
      subscription = item.subscription
    }
    },
    # custom topic subscriptions
    {
      for item in flatten([
        for topic_key, topic in lookup(var.config, "custom_topics", {}) : [
          for sub_key, sub in lookup(topic, "event_subscriptions", {}) : {
            id           = "${topic_key}-${sub_key}"
            topic_key    = topic_key
            subscription = sub
            name = try(
              sub.name, join("-", [var.naming.eventgrid_event_subscription, sub_key])
            )
          }
        ]
        ]) : item.id => {

        name         = item.name
        scope        = azurerm_eventgrid_topic.this[item.topic_key].id
        subscription = item.subscription
      }
    },
    # standalone subscriptions
    {
      for key, sub in lookup(var.config, "event_subscriptions", {}) : key => {
        scope        = sub.scope
        subscription = sub
        name         = try(sub.name, join("-", [var.naming.eventgrid_event_subscription, key]))
      }
    }
  )

  name                                 = each.value.name
  scope                                = each.value.scope
  event_delivery_schema                = try(each.value.subscription.event_delivery_schema, null)
  included_event_types                 = try(each.value.subscription.included_event_types, null)
  labels                               = try(each.value.subscription.labels, null)
  hybrid_connection_endpoint_id        = try(each.value.subscription.hybrid_connection_endpoint_id, null)
  advanced_filtering_on_arrays_enabled = try(each.value.subscription.advanced_filtering_on_arrays_enabled, false)
  expiration_time_utc                  = try(each.value.subscription.expiration_time_utc, null)

  service_bus_queue_endpoint_id = lookup(
    each.value.subscription, "service_bus_queue_endpoint_id",
    lookup(each.value.subscription, "endpoint_type", null) == "servicebus_queue" ?
    lookup(each.value.subscription, "endpoint_id", null) : null
  )
  service_bus_topic_endpoint_id = lookup(
    each.value.subscription, "service_bus_topic_endpoint_id",
    lookup(each.value.subscription, "endpoint_type", null) == "servicebus_topic" ?
    lookup(each.value.subscription, "endpoint_id", null) : null
  )
  eventhub_endpoint_id = lookup(
    each.value.subscription, "eventhub_endpoint_id",
    lookup(each.value.subscription, "endpoint_type", null) == "eventhub" ?
    lookup(each.value.subscription, "endpoint_id", null) : null
  )

  dynamic "azure_function_endpoint" {
    for_each = lookup(each.value.subscription, "azure_function_endpoint", null) != null ? { "default" = each.value.subscription.azure_function_endpoint } : {}

    content {
      function_id                       = azure_function_endpoint.value.function_id
      max_events_per_batch              = try(azure_function_endpoint.value.max_events_per_batch, null)
      preferred_batch_size_in_kilobytes = try(azure_function_endpoint.value.preferred_batch_size_in_kilobytes, null)
    }
  }

  dynamic "webhook_endpoint" {
    for_each = lookup(each.value.subscription, "webhook_endpoint", null) != null ? { "default" = each.value.subscription.webhook_endpoint } : {}

    content {
      url                               = webhook_endpoint.value.url
      preferred_batch_size_in_kilobytes = try(webhook_endpoint.value.preferred_batch_size_in_kilobytes, null)
      max_events_per_batch              = try(webhook_endpoint.value.max_events_per_batch, null)
      active_directory_tenant_id        = try(webhook_endpoint.value.active_directory_tenant_id, null)
      active_directory_app_id_or_uri    = try(webhook_endpoint.value.active_directory_app_id_or_uri, null)
    }
  }

  dynamic "retry_policy" {
    for_each = lookup(each.value.subscription, "retry_policy", null) != null ? { "default" = each.value.subscription.retry_policy } : {}

    content {
      max_delivery_attempts = retry_policy.value.max_delivery_attempts
      event_time_to_live    = retry_policy.value.event_time_to_live
    }
  }

  dynamic "subject_filter" {
    for_each = contains(keys(each.value.subscription), "subject_filter") ? [each.value.subscription.subject_filter] : (
      contains(keys(each.value.subscription), "filters") ? [each.value.subscription.filters] : []
    )

    content {
      subject_begins_with = lookup(subject_filter.value, "subject_begins_with", "/")
      subject_ends_with   = lookup(subject_filter.value, "subject_ends_with", null)
      case_sensitive      = lookup(subject_filter.value, "case_sensitive", false)
    }
  }

  dynamic "advanced_filter" {
    for_each = lookup(each.value.subscription, "advanced_filter", null) != null ? { "default" = each.value.subscription.advanced_filter } : {}

    content {
      dynamic "bool_equals" {
        for_each = lookup(
          advanced_filter.value, "bool_equals", {}
        )

        content {
          key   = bool_equals.key
          value = bool_equals.value
        }
      }

      dynamic "number_greater_than" {
        for_each = lookup(
          advanced_filter.value, "number_greater_than", {}
        )

        content {
          key   = number_greater_than.key
          value = number_greater_than.value
        }
      }

      dynamic "number_greater_than_or_equals" {
        for_each = lookup(
          advanced_filter.value, "number_greater_than_or_equals", {}
        )

        content {
          key   = number_greater_than_or_equals.key
          value = number_greater_than_or_equals.value
        }
      }
      dynamic "number_less_than" {
        for_each = lookup(
          advanced_filter.value, "number_less_than", {}
        )

        content {
          key   = number_less_than.key
          value = number_less_than.value
        }
      }

      dynamic "number_less_than_or_equals" {
        for_each = lookup(
          advanced_filter.value, "number_less_than_or_equals", {}
        )

        content {
          key   = number_less_than_or_equals.key
          value = number_less_than_or_equals.value
        }
      }

      dynamic "number_in" {
        for_each = lookup(
          advanced_filter.value, "number_in", {}
        )

        content {
          key    = number_in.key
          values = number_in.value
        }
      }

      dynamic "number_not_in" {
        for_each = lookup(
          advanced_filter.value, "number_not_in", {}
        )

        content {
          key    = number_not_in.key
          values = number_not_in.value
        }
      }

      dynamic "string_begins_with" {
        for_each = lookup(
          advanced_filter.value, "string_begins_with", {}
        )

        content {
          key    = string_begins_with.key
          values = string_begins_with.value
        }
      }

      dynamic "string_ends_with" {
        for_each = lookup(
          advanced_filter.value, "string_ends_with", {}
        )

        content {
          key    = string_ends_with.key
          values = string_ends_with.value
        }
      }

      dynamic "string_contains" {
        for_each = lookup(
          advanced_filter.value, "string_contains", {}
        )

        content {
          key    = string_contains.key
          values = string_contains.value
        }
      }

      dynamic "string_in" {
        for_each = lookup(
          advanced_filter.value, "string_in", {}
        )

        content {
          key    = string_in.key
          values = string_in.value
        }
      }

      dynamic "string_not_in" {
        for_each = lookup(
          advanced_filter.value, "string_not_in", {}
        )

        content {
          key    = string_not_in.key
          values = string_not_in.value
        }
      }
    }
  }

  dynamic "delivery_property" {
    for_each = lookup(
      each.value.subscription, "delivery_property_mappings", {}
    )

    content {
      header_name  = delivery_property.value.header_name
      type         = delivery_property.value.type
      value        = lookup(delivery_property.value, "value", null)
      source_field = lookup(delivery_property.value, "source_field", null)
      secret       = lookup(delivery_property.value, "secret", null)
    }
  }
}

# system topics
resource "azurerm_eventgrid_system_topic" "this" {
  for_each = lookup(
    var.config, "system_topics", {}
  )

  name = try(
    each.value.name, join("-", [var.naming.eventgrid_topic, each.key])
  )

  resource_group_name    = coalesce(lookup(var.config, "resource_group", null), var.resource_group)
  location               = coalesce(lookup(var.config, "location", null), var.location)
  source_arm_resource_id = each.value.source_arm_resource_id
  topic_type             = each.value.topic_type

  tags = try(
    var.config.tags, var.tags, null
  )
}

# system topic event subscriptions
resource "azurerm_eventgrid_system_topic_event_subscription" "this" {
  for_each = {
    for item in flatten([
      for topic_key, topic in lookup(var.config, "system_topics", {}) : [
        for sub_key, sub in lookup(topic, "event_subscriptions", {}) : {
          id                            = "${topic_key}-${sub_key}"
          topic_key                     = topic_key
          name                          = sub_key
          topic_name                    = azurerm_eventgrid_system_topic.this[topic_key].name
          included_event_types          = try(sub.included_event_types, [])
          event_delivery_schema         = try(sub.event_delivery_schema, null)
          webhook_endpoint              = try(sub.webhook_endpoint, null)
          service_bus_queue_endpoint_id = try(sub.service_bus_queue_endpoint_id, null)
          service_bus_topic_endpoint_id = try(sub.service_bus_topic_endpoint_id, null)
          eventhub_endpoint_id          = try(sub.eventhub_endpoint_id, null)
          subject_filter                = try(sub.subject_filter, null)
          retry_policy                  = try(sub.retry_policy, null)
          delivery_property_mappings    = try(sub.delivery_property_mappings, null)
        }
      ]
    ]) : item.id => item
  }

  name                = each.key
  system_topic        = each.value.topic_name
  resource_group_name = coalesce(lookup(var.config, "resource_group", null), var.resource_group)

  event_delivery_schema                = each.value.event_delivery_schema
  included_event_types                 = each.value.included_event_types
  service_bus_queue_endpoint_id        = each.value.service_bus_queue_endpoint_id
  service_bus_topic_endpoint_id        = each.value.service_bus_topic_endpoint_id
  eventhub_endpoint_id                 = each.value.eventhub_endpoint_id
  labels                               = try(each.value.labels, [])
  expiration_time_utc                  = try(each.value.expiration_time_utc, null)
  advanced_filtering_on_arrays_enabled = try(each.value.advanced_filtering_on_arrays_enabled, false)
  hybrid_connection_endpoint_id        = try(each.value.hybrid_connection_endpoint_id, null)


  dynamic "storage_blob_dead_letter_destination" {
    for_each = lookup(each.value, "storage_blob_dead_letter_destination", null) != null ? { "default" = each.value.storage_blob_dead_letter_destination } : {}

    content {
      storage_account_id          = storage_blob_dead_letter_destination.value.storage_account_id
      storage_blob_container_name = storage_blob_dead_letter_destination.value.storage_blob_container_name
    }
  }

  dynamic "storage_queue_endpoint" {
    for_each = lookup(each.value, "storage_queue_endpoint", null) != null ? { "default" = each.value.storage_queue_endpoint } : {}

    content {
      storage_account_id                    = storage_queue_endpoint.value.storage_account_id
      queue_name                            = storage_queue_endpoint.value.queue_name
      queue_message_time_to_live_in_seconds = try(storage_queue_endpoint.value.queue_message_time_to_live_in_seconds, null)
    }
  }

  dynamic "delivery_identity" {
    for_each = lookup(each.value, "delivery_identity", null) != null ? { "default" = each.value.delivery_identity } : {}

    content {
      type                   = delivery_identity.value.type
      user_assigned_identity = try(delivery_identity.value.user_assigned_identity, null)
    }
  }

  dynamic "dead_letter_identity" {
    for_each = lookup(each.value, "dead_letter_identity", null) != null ? { "default" = each.value.dead_letter_identity } : {}

    content {
      type                   = dead_letter_identity.value.type
      user_assigned_identity = try(dead_letter_identity.value.user_assigned_identity, null)
    }
  }

  dynamic "azure_function_endpoint" {
    for_each = lookup(each.value, "azure_function_endpoint", null) != null ? { "default" = each.value.azure_function_endpoint } : {}

    content {
      function_id                       = azure_function_endpoint.value.function_id
      max_events_per_batch              = try(azure_function_endpoint.value.max_events_per_batch, null)
      preferred_batch_size_in_kilobytes = try(azure_function_endpoint.value.preferred_batch_size_in_kilobytes, null)
    }
  }

  dynamic "webhook_endpoint" {
    for_each = lookup(each.value, "webhook_endpoint", null) != null ? { "default" = each.value.webhook_endpoint } : {}

    content {
      url                               = webhook_endpoint.value.url
      preferred_batch_size_in_kilobytes = try(webhook_endpoint.value.preferred_batch_size_in_kilobytes, null)
      max_events_per_batch              = try(webhook_endpoint.value.max_events_per_batch, null)
      active_directory_app_id_or_uri    = try(webhook_endpoint.value.active_directory_app_id_or_uri, null)
      active_directory_tenant_id        = try(webhook_endpoint.value.active_directory_tenant_id, null)
    }
  }

  dynamic "subject_filter" { //max 1
    for_each = lookup(each.value, "subject_filter", null) != null ? { "default" = each.value.subject_filter } : {}

    content {
      subject_begins_with = lookup(subject_filter.value, "subject_begins_with", "/")
      subject_ends_with   = lookup(subject_filter.value, "subject_ends_with", null)
      case_sensitive      = lookup(subject_filter.value, "case_sensitive", false)
    }
  }

  dynamic "retry_policy" {
    for_each = lookup(each.value, "retry_policy", null) != null ? { "default" = each.value.retry_policy } : {}

    content {
      max_delivery_attempts = retry_policy.value.max_delivery_attempts
      event_time_to_live    = retry_policy.value.event_time_to_live
    }
  }

  dynamic "delivery_property" {
    for_each = each.value.delivery_property_mappings != null ? each.value.delivery_property_mappings : {}

    content {
      header_name  = delivery_property.value.header_name
      type         = delivery_property.value.type
      value        = lookup(delivery_property.value, "value", null)
      source_field = lookup(delivery_property.value, "source_field", null)
      secret       = lookup(delivery_property.value, "secret", null)
    }
  }

  dynamic "advanced_filter" {
    for_each = lookup(each.value, "advanced_filter", null) != null ? { "default" = each.value.advanced_filter } : {}

    content {
      dynamic "bool_equals" {
        for_each = lookup(
          advanced_filter.value, "bool_equals", {}
        )

        content {
          key   = bool_equals.key
          value = bool_equals.value
        }
      }

      dynamic "number_greater_than" {
        for_each = lookup(
          advanced_filter.value, "number_greater_than", {}
        )

        content {
          key   = number_greater_than.key
          value = number_greater_than.value
        }
      }

      dynamic "number_greater_than_or_equals" {
        for_each = lookup(
          advanced_filter.value, "number_greater_than_or_equals", {}
        )

        content {
          key   = number_greater_than_or_equals.key
          value = number_greater_than_or_equals.value
        }
      }

      dynamic "number_less_than" {
        for_each = lookup(
          advanced_filter.value, "number_less_than", {}
        )

        content {
          key   = number_less_than.key
          value = number_less_than.value
        }
      }

      dynamic "number_less_than_or_equals" {
        for_each = lookup(
          advanced_filter.value, "number_less_than_or_equals", {}
        )

        content {
          key   = number_less_than_or_equals.key
          value = number_less_than_or_equals.value
        }
      }

      dynamic "number_in" {
        for_each = lookup(
          advanced_filter.value, "number_in", {}
        )

        content {
          key    = number_in.key
          values = number_in.value
        }
      }

      dynamic "number_not_in" {
        for_each = lookup(
          advanced_filter.value, "number_not_in", {}
        )

        content {
          key    = number_not_in.key
          values = number_not_in.value
        }
      }

      dynamic "string_begins_with" {
        for_each = lookup(
          advanced_filter.value, "string_begins_with", {}
        )

        content {
          key    = string_begins_with.key
          values = string_begins_with.value
        }
      }

      dynamic "string_ends_with" {
        for_each = lookup(
          advanced_filter.value, "string_ends_with", {}
        )

        content {
          key    = string_ends_with.key
          values = string_ends_with.value
        }
      }

      dynamic "string_contains" {
        for_each = lookup(
          advanced_filter.value, "string_contains", {}
        )

        content {
          key    = string_contains.key
          values = string_contains.value
        }
      }

      dynamic "string_in" {
        for_each = lookup(
          advanced_filter.value, "string_in", {}
        )

        content {
          key    = string_in.key
          values = string_in.value
        }
      }

      dynamic "string_not_in" {
        for_each = lookup(
          advanced_filter.value, "string_not_in", {}
        )

        content {
          key    = string_not_in.key
          values = string_not_in.value
        }
      }
    }
  }
}

# custom topics
resource "azurerm_eventgrid_topic" "this" {
  for_each = lookup(
    var.config, "custom_topics", {}
  )

  name = try(
    each.value.name, join("-", [var.naming.eventgrid_topic, each.key])
  )

  resource_group_name           = coalesce(lookup(var.config, "resource_group", null), var.resource_group)
  location                      = coalesce(lookup(var.config, "location", null), var.location)
  input_schema                  = try(each.value.input_schema, "EventGridSchema")
  public_network_access_enabled = try(each.value.public_network_access_enabled, true)
  local_auth_enabled            = try(each.value.local_auth_enabled, false)
  tags                          = try(var.config.tags, var.tags, null)
  inbound_ip_rule               = try(each.value.inbound_ip_rule, null)

  dynamic "input_mapping_fields" {
    for_each = lookup(each.value, "input_mapping_fields", null) != null ? { "default" = each.value.input_mapping_fields } : {}

    content {
      id           = try(input_mapping_fields.value.id, null)
      topic        = try(input_mapping_fields.value.topic, null)
      subject      = try(input_mapping_fields.value.subject, null)
      event_time   = try(input_mapping_fields.value.event_time, null)
      event_type   = try(input_mapping_fields.value.event_type, null)
      data_version = try(input_mapping_fields.value.data_version, null)
    }
  }

  dynamic "input_mapping_default_values" {
    for_each = lookup(each.value, "input_mapping_default_values", null) != null ? { "default" = each.value.input_mapping_default_values } : {}

    content {
      data_version = try(input_mapping_default_values.value.data_version, null)
      event_type   = try(input_mapping_default_values.value.event_type, null)
      subject      = try(input_mapping_default_values.value.subject, null)
    }
  }
}
