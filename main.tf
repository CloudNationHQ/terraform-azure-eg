# domains
resource "azurerm_eventgrid_domain" "this" {
  for_each = lookup(
    var.config, "domains", {}
  )

  resource_group_name = coalesce(
    lookup(
      var.config, "resource_group_name", null
    ), var.resource_group_name
  )

  location = coalesce(
    lookup(var.config, "location", null
    ), var.location
  )

  name = coalesce(
    each.value.name, join("-", [var.naming.eventgrid_domain, each.key])
  )

  dynamic "input_mapping_default_values" {
    for_each = lookup(each.value, "input_mapping_default_values", null) != null ? { "default" = each.value.input_mapping_default_values } : {}

    content {
      subject      = input_mapping_default_values.value.subject
      event_type   = input_mapping_default_values.value.event_type
      data_version = input_mapping_default_values.value.data_version
    }
  }

  dynamic "input_mapping_fields" {
    for_each = lookup(each.value, "input_mapping_fields", null) != null ? { "default" = each.value.input_mapping_fields } : {}

    content {
      id           = input_mapping_fields.value.id
      data_version = input_mapping_fields.value.data_version
      event_type   = input_mapping_fields.value.event_type
      subject      = input_mapping_fields.value.subject
      topic        = input_mapping_fields.value.topic
      event_time   = input_mapping_fields.value.event_time
    }
  }

  dynamic "identity" {
    for_each = lookup(var.config, "identity", null) != null ? [var.config.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  inbound_ip_rule                           = var.config.inbound_ip_rule
  input_schema                              = var.config.input_schema
  public_network_access_enabled             = var.config.public_network_access_enabled
  auto_delete_topic_with_last_subscription  = var.config.auto_delete_topic_with_last_subscription
  local_auth_enabled                        = var.config.local_auth_enabled
  auto_create_topic_with_first_subscription = var.config.auto_create_topic_with_first_subscription

  tags = coalesce(
    var.config.tags, var.tags
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
        name = coalesce(
          topic.name, join("-", [var.naming.eventgrid_domain_topic, topic_key])
        )
      }
    }
  ])...)

  resource_group_name = coalesce(
    lookup(
      var.config, "resource_group_name", null
    ), var.resource_group_name
  )

  name        = each.value.name
  domain_name = each.value.domain_name
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
            name = coalesce(
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
            name = coalesce(
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
        name = coalesce(
          sub.name, join("-", [var.naming.eventgrid_event_subscription, key])
        )
      }
    }
  )

  name                                 = each.value.name
  scope                                = each.value.scope
  event_delivery_schema                = each.value.subscription.event_delivery_schema
  included_event_types                 = each.value.subscription.included_event_types
  labels                               = each.value.subscription.labels
  hybrid_connection_endpoint_id        = each.value.subscription.hybrid_connection_endpoint_id
  advanced_filtering_on_arrays_enabled = each.value.subscription.advanced_filtering_on_arrays_enabled
  expiration_time_utc                  = each.value.subscription.expiration_time_utc

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


  dynamic "dead_letter_identity" {
    for_each = lookup(each.value.subscription, "dead_letter_identity", null) != null ? { "default" = each.value.subscription.dead_letter_identity } : {}

    content {
      type                   = dead_letter_identity.value.type
      user_assigned_identity = dead_letter_identity.value.user_assigned_identity
    }
  }

  dynamic "delivery_identity" {
    for_each = lookup(each.value.subscription, "delivery_identity", null) != null ? { "default" = each.value.subscription.delivery_identity } : {}

    content {
      type                   = delivery_identity.value.type
      user_assigned_identity = delivery_identity.value.user_assigned_identity
    }
  }

  dynamic "storage_blob_dead_letter_destination" {
    for_each = lookup(each.value.subscription, "storage_blob_dead_letter_destination", null) != null ? { "default" = each.value.subscription.storage_blob_dead_letter_destination } : {}

    content {
      storage_account_id          = storage_blob_dead_letter_destination.value.storage_account_id
      storage_blob_container_name = storage_blob_dead_letter_destination.value.storage_blob_container_name
    }
  }

  dynamic "storage_queue_endpoint" {
    for_each = lookup(each.value.subscription, "storage_queue_endpoint", null) != null ? { "default" = each.value.subscription.storage_queue_endpoint } : {}

    content {
      storage_account_id                    = storage_queue_endpoint.value.storage_account_id
      queue_name                            = storage_queue_endpoint.value.queue_name
      queue_message_time_to_live_in_seconds = storage_queue_endpoint.value.queue_message_time_to_live_in_seconds
    }
  }

  dynamic "azure_function_endpoint" {
    for_each = lookup(each.value.subscription, "azure_function_endpoint", null) != null ? { "default" = each.value.subscription.azure_function_endpoint } : {}

    content {
      function_id                       = azure_function_endpoint.value.function_id
      max_events_per_batch              = azure_function_endpoint.value.max_events_per_batch
      preferred_batch_size_in_kilobytes = azure_function_endpoint.value.preferred_batch_size_in_kilobytes
    }
  }

  dynamic "webhook_endpoint" {
    for_each = lookup(each.value.subscription, "webhook_endpoint", null) != null ? { "default" = each.value.subscription.webhook_endpoint } : {}

    content {
      url                               = webhook_endpoint.value.url
      preferred_batch_size_in_kilobytes = webhook_endpoint.value.preferred_batch_size_in_kilobytes
      max_events_per_batch              = webhook_endpoint.value.max_events_per_batch
      active_directory_tenant_id        = webhook_endpoint.value.active_directory_tenant_id
      active_directory_app_id_or_uri    = webhook_endpoint.value.active_directory_app_id_or_uri
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
    for_each = contains(keys(each.value.subscription), "subject_filter") && each.value.subscription.subject_filter != null ? [each.value.subscription.subject_filter] : (
      contains(keys(each.value.subscription), "filters") && each.value.subscription.filters != null ? [each.value.subscription.filters] : []
    )

    content {
      subject_begins_with = subject_filter.value.subject_begins_with
      subject_ends_with   = subject_filter.value.subject_ends_with
      case_sensitive      = subject_filter.value.case_sensitive
    }
  }

  dynamic "advanced_filter" {
    for_each = lookup(each.value.subscription, "advanced_filter", null) != null ? { "default" = each.value.subscription.advanced_filter } : {}

    content {
      dynamic "bool_equals" {
        for_each = advanced_filter.value.bool_equals

        content {
          key   = bool_equals.key
          value = bool_equals.value
        }
      }

      dynamic "string_not_contains" {
        for_each = advanced_filter.value.string_not_contains

        content {
          key    = string_not_contains.key
          values = string_not_contains.value
        }
      }

      dynamic "string_not_begins_with" {
        for_each = advanced_filter.value.string_not_begins_with

        content {
          key    = string_not_begins_with.key
          values = string_not_begins_with.value
        }
      }

      dynamic "number_in_range" {
        for_each = advanced_filter.value.number_in_range

        content {
          key    = number_in_range.key
          values = number_in_range.value
        }
      }

      dynamic "number_not_in_range" {
        for_each = advanced_filter.value.number_not_in_range

        content {
          key    = number_not_in_range.key
          values = number_not_in_range.value
        }
      }

      dynamic "is_not_null" {
        for_each = advanced_filter.value.is_not_null

        content {
          key = is_not_null.value
        }
      }

      dynamic "is_null_or_undefined" {
        for_each = advanced_filter.value.is_null_or_undefined

        content {
          key = is_null_or_undefined.value
        }
      }

      dynamic "number_greater_than" {
        for_each = advanced_filter.value.number_greater_than

        content {
          key   = number_greater_than.key
          value = number_greater_than.value
        }
      }

      dynamic "number_greater_than_or_equals" {
        for_each = advanced_filter.value.number_greater_than_or_equals

        content {
          key   = number_greater_than_or_equals.key
          value = number_greater_than_or_equals.value
        }
      }
      dynamic "number_less_than" {
        for_each = advanced_filter.value.number_less_than

        content {
          key   = number_less_than.key
          value = number_less_than.value
        }
      }

      dynamic "number_less_than_or_equals" {
        for_each = advanced_filter.value.number_less_than_or_equals

        content {
          key   = number_less_than_or_equals.key
          value = number_less_than_or_equals.value
        }
      }

      dynamic "number_in" {
        for_each = advanced_filter.value.number_in

        content {
          key    = number_in.key
          values = number_in.value
        }
      }

      dynamic "number_not_in" {
        for_each = advanced_filter.value.number_not_in

        content {
          key    = number_not_in.key
          values = number_not_in.value
        }
      }

      dynamic "string_begins_with" {
        for_each = advanced_filter.value.string_begins_with

        content {
          key    = string_begins_with.key
          values = string_begins_with.value
        }
      }

      dynamic "string_ends_with" {
        for_each = advanced_filter.value.string_ends_with

        content {
          key    = string_ends_with.key
          values = string_ends_with.value
        }
      }

      dynamic "string_contains" {
        for_each = advanced_filter.value.string_contains

        content {
          key    = string_contains.key
          values = string_contains.value
        }
      }

      dynamic "string_in" {
        for_each = advanced_filter.value.string_in

        content {
          key    = string_in.key
          values = string_in.value
        }
      }

      dynamic "string_not_ends_with" {
        for_each = advanced_filter.value.string_not_ends_with

        content {
          key    = string_not_ends_with.key
          values = string_not_ends_with.value
        }
      }

      dynamic "string_not_in" {
        for_each = advanced_filter.value.string_not_in

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
      value        = delivery_property.value.value
      source_field = delivery_property.value.source_field
      secret       = delivery_property.value.secret
    }
  }
}

# system topics
resource "azurerm_eventgrid_system_topic" "this" {
  for_each = lookup(
    var.config, "system_topics", {}
  )

  name = coalesce(
    each.value.name, join("-", [var.naming.eventgrid_topic, each.key])
  )

  resource_group_name = coalesce(
    lookup(
      var.config, "resource_group_name", null
    ), var.resource_group_name
  )

  location = coalesce(
    lookup(var.config, "location", null
    ), var.location
  )

  source_arm_resource_id = each.value.source_arm_resource_id
  topic_type             = each.value.topic_type

  tags = coalesce(
    var.config.tags, var.tags
  )

  dynamic "identity" {
    for_each = lookup(each.value, "identity", null) != null ? [var.config.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
}

# system topic event subscriptions
resource "azurerm_eventgrid_system_topic_event_subscription" "this" {
  for_each = {
    for item in flatten([
      for topic_key, topic in lookup(var.config, "system_topics", {}) : [
        for sub_key, sub in lookup(topic, "event_subscriptions", {}) : {
          id                                   = "${topic_key}-${sub_key}"
          topic_key                            = topic_key
          name                                 = sub_key
          topic_name                           = azurerm_eventgrid_system_topic.this[topic_key].name
          included_event_types                 = sub.included_event_types
          event_delivery_schema                = sub.event_delivery_schema
          webhook_endpoint                     = sub.webhook_endpoint
          service_bus_queue_endpoint_id        = sub.service_bus_queue_endpoint_id
          service_bus_topic_endpoint_id        = sub.service_bus_topic_endpoint_id
          eventhub_endpoint_id                 = sub.eventhub_endpoint_id
          subject_filter                       = sub.subject_filter
          retry_policy                         = sub.retry_policy
          delivery_property_mappings           = sub.delivery_property_mappings
          labels                               = sub.labels
          expiration_time_utc                  = sub.expiration_time_utc
          advanced_filtering_on_arrays_enabled = sub.advanced_filtering_on_arrays_enabled
          hybrid_connection_endpoint_id        = sub.hybrid_connection_endpoint_id
        }
      ]
    ]) : item.id => item
  }

  name         = each.key
  system_topic = each.value.topic_name

  resource_group_name = coalesce(
    lookup(
      var.config, "resource_group_name", null
    ), var.resource_group_name
  )

  event_delivery_schema                = each.value.event_delivery_schema
  included_event_types                 = each.value.included_event_types
  service_bus_queue_endpoint_id        = each.value.service_bus_queue_endpoint_id
  service_bus_topic_endpoint_id        = each.value.service_bus_topic_endpoint_id
  eventhub_endpoint_id                 = each.value.eventhub_endpoint_id
  labels                               = each.value.labels
  expiration_time_utc                  = each.value.expiration_time_utc
  advanced_filtering_on_arrays_enabled = each.value.advanced_filtering_on_arrays_enabled
  hybrid_connection_endpoint_id        = each.value.hybrid_connection_endpoint_id

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
      queue_message_time_to_live_in_seconds = storage_queue_endpoint.value.queue_message_time_to_live_in_seconds
    }
  }

  dynamic "delivery_identity" {
    for_each = lookup(each.value, "delivery_identity", null) != null ? { "default" = each.value.delivery_identity } : {}

    content {
      type                   = delivery_identity.value.type
      user_assigned_identity = delivery_identity.value.user_assigned_identity
    }
  }

  dynamic "dead_letter_identity" {
    for_each = lookup(each.value, "dead_letter_identity", null) != null ? { "default" = each.value.dead_letter_identity } : {}

    content {
      type                   = dead_letter_identity.value.type
      user_assigned_identity = dead_letter_identity.value.user_assigned_identity
    }
  }

  dynamic "azure_function_endpoint" {
    for_each = lookup(each.value, "azure_function_endpoint", null) != null ? { "default" = each.value.azure_function_endpoint } : {}

    content {
      function_id                       = azure_function_endpoint.value.function_id
      max_events_per_batch              = azure_function_endpoint.value.max_events_per_batch
      preferred_batch_size_in_kilobytes = azure_function_endpoint.value.preferred_batch_size_in_kilobytes
    }
  }

  dynamic "webhook_endpoint" {
    for_each = lookup(each.value, "webhook_endpoint", null) != null ? { "default" = each.value.webhook_endpoint } : {}

    content {
      url                               = webhook_endpoint.value.url
      preferred_batch_size_in_kilobytes = webhook_endpoint.value.preferred_batch_size_in_kilobytes
      max_events_per_batch              = webhook_endpoint.value.max_events_per_batch
      active_directory_app_id_or_uri    = webhook_endpoint.value.active_directory_app_id_or_uri
      active_directory_tenant_id        = webhook_endpoint.value.active_directory_tenant_id
    }
  }

  dynamic "subject_filter" { //max 1
    for_each = lookup(each.value, "subject_filter", null) != null ? { "default" = each.value.subject_filter } : {}

    content {
      subject_begins_with = subject_filter.value.subject_begins_with
      subject_ends_with   = subject_filter.value.subject_ends_with
      case_sensitive      = subject_filter.value.case_sensitive
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
      value        = delivery_property.value.value
      source_field = delivery_property.value.source_field
      secret       = delivery_property.value.secret
    }
  }

  dynamic "advanced_filter" {
    for_each = lookup(each.value, "advanced_filter", null) != null ? { "default" = each.value.advanced_filter } : {}

    content {
      dynamic "bool_equals" {
        for_each = advanced_filter.value.bool_equals

        content {
          key   = bool_equals.key
          value = bool_equals.value
        }
      }

      dynamic "number_in_range" {
        for_each = advanced_filter.value.number_in_range

        content {
          key    = number_in_range.key
          values = number_in_range.value
        }
      }

      dynamic "number_not_in_range" {
        for_each = advanced_filter.value.number_not_in_range

        content {
          key    = number_not_in_range.key
          values = number_not_in_range.value
        }
      }

      dynamic "string_not_contains" {
        for_each = advanced_filter.value.string_not_contains

        content {
          key    = string_not_contains.key
          values = string_not_contains.value
        }
      }

      dynamic "string_not_begins_with" {
        for_each = advanced_filter.value.string_not_begins_with

        content {
          key    = string_not_begins_with.key
          values = string_not_begins_with.value
        }
      }

      dynamic "is_not_null" {
        for_each = advanced_filter.value.is_not_null

        content {
          key = try(is_not_null.value, null)
        }
      }

      dynamic "is_null_or_undefined" {
        for_each = advanced_filter.value.is_null_or_undefined

        content {
          key = is_null_or_undefined.value
        }
      }

      dynamic "number_greater_than" {
        for_each = advanced_filter.value.number_greater_than

        content {
          key   = number_greater_than.key
          value = number_greater_than.value
        }
      }

      dynamic "number_greater_than_or_equals" {
        for_each = advanced_filter.value.number_greater_than_or_equals

        content {
          key   = number_greater_than_or_equals.key
          value = number_greater_than_or_equals.value
        }
      }

      dynamic "number_less_than" {
        for_each = advanced_filter.value.number_less_than

        content {
          key   = number_less_than.key
          value = number_less_than.value
        }
      }

      dynamic "number_less_than_or_equals" {
        for_each = advanced_filter.value.number_less_than_or_equals

        content {
          key   = number_less_than_or_equals.key
          value = number_less_than_or_equals.value
        }
      }

      dynamic "number_in" {
        for_each = advanced_filter.value.number_in

        content {
          key    = number_in.key
          values = number_in.value
        }
      }

      dynamic "number_not_in" {
        for_each = advanced_filter.value.number_not_in

        content {
          key    = number_not_in.key
          values = number_not_in.value
        }
      }

      dynamic "string_begins_with" {
        for_each = advanced_filter.value.string_begins_with

        content {
          key    = string_begins_with.key
          values = string_begins_with.value
        }
      }

      dynamic "string_ends_with" {
        for_each = advanced_filter.value.string_ends_with

        content {
          key    = string_ends_with.key
          values = string_ends_with.value
        }
      }

      dynamic "string_contains" {
        for_each = advanced_filter.value.string_contains

        content {
          key    = string_contains.key
          values = string_contains.value
        }
      }

      dynamic "string_in" {
        for_each = advanced_filter.value.string_in

        content {
          key    = string_in.key
          values = string_in.value
        }
      }

      dynamic "string_not_ends_with" {
        for_each = advanced_filter.value.string_not_ends_with

        content {
          key    = string_not_ends_with.key
          values = string_not_ends_with.value
        }
      }

      dynamic "string_not_in" {
        for_each = advanced_filter.value.string_not_in

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

  resource_group_name = coalesce(
    lookup(
      var.config, "resource_group_name", null
    ), var.resource_group_name
  )

  location = coalesce(
    lookup(var.config, "location", null
    ), var.location
  )

  name = coalesce(
    each.value.name, join("-", [var.naming.eventgrid_topic, each.key])
  )

  input_schema                  = each.value.input_schema
  public_network_access_enabled = each.value.public_network_access_enabled
  local_auth_enabled            = each.value.local_auth_enabled
  inbound_ip_rule               = each.value.inbound_ip_rule

  tags = coalesce(
    var.config.tags, var.tags
  )

  dynamic "identity" {
    for_each = lookup(each.value, "identity", null) != null ? [var.config.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "input_mapping_fields" {
    for_each = lookup(each.value, "input_mapping_fields", null) != null ? { "default" = each.value.input_mapping_fields } : {}

    content {
      id           = input_mapping_fields.value.id
      topic        = input_mapping_fields.value.topic
      subject      = input_mapping_fields.value.subject
      event_time   = input_mapping_fields.value.event_time
      event_type   = input_mapping_fields.value.event_type
      data_version = input_mapping_fields.value.data_version
    }
  }

  dynamic "input_mapping_default_values" {
    for_each = lookup(each.value, "input_mapping_default_values", null) != null ? { "default" = each.value.input_mapping_default_values } : {}

    content {
      data_version = input_mapping_default_values.value.data_version
      event_type   = input_mapping_default_values.value.event_type
      subject      = input_mapping_default_values.value.subject
    }
  }
}
