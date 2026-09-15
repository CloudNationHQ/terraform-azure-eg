# domains
resource "azurerm_eventgrid_domain" "this" {
  for_each = var.eventgrid.domains

  resource_group_name = coalesce(
    var.eventgrid.resource_group_name, var.resource_group_name
  )

  location = coalesce(
    var.eventgrid.location, var.location
  )

  name = coalesce(
    each.value.name, each.key
  )

  dynamic "input_mapping_default_values" {
    for_each = each.value.input_mapping_default_values != null ? { "this" = each.value.input_mapping_default_values } : {}

    content {
      subject      = input_mapping_default_values.value.subject
      event_type   = input_mapping_default_values.value.event_type
      data_version = input_mapping_default_values.value.data_version
    }
  }

  dynamic "input_mapping_fields" {
    for_each = each.value.input_mapping_fields != null ? { "this" = each.value.input_mapping_fields } : {}

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
    for_each = var.eventgrid.identity != null ? { "this" = var.eventgrid.identity } : {}

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "inbound_ip_rule" {
    for_each = each.value.inbound_ip_rule

    content {
      ip_mask = inbound_ip_rule.value.ip_mask
      action  = inbound_ip_rule.value.action
    }
  }

  input_schema                              = var.eventgrid.input_schema
  public_network_access_enabled             = var.eventgrid.public_network_access_enabled
  auto_delete_topic_with_last_subscription  = var.eventgrid.auto_delete_topic_with_last_subscription
  local_auth_enabled                        = var.eventgrid.local_auth_enabled
  auto_create_topic_with_first_subscription = var.eventgrid.auto_create_topic_with_first_subscription

  tags = coalesce(
    var.eventgrid.tags, var.tags
  )
}

# domain topics
resource "azurerm_eventgrid_domain_topic" "this" {
  for_each = merge(flatten([
    for domain_key, domain in var.eventgrid.domains : {
      for topic_key, topic in domain.domain_topics :
      "${domain_key}-${topic_key}" => {
        domain_name = azurerm_eventgrid_domain.this[domain_key].name
        domain_key  = domain_key
        name = coalesce(
          topic.name, topic_key
        )
      }
    }
  ])...)

  resource_group_name = coalesce(
    var.eventgrid.resource_group_name, var.resource_group_name
  )

  name        = each.value.name
  domain_name = each.value.domain_name
}

# subscriptions
resource "azurerm_eventgrid_event_subscription" "this" {
  for_each = merge(flatten([
    # domain topic subscriptions
    [for domain_key, domain in var.eventgrid.domains : [
      for topic_key, topic in domain.domain_topics : {
        for sub_key, sub in topic.event_subscriptions :
        "${domain_key}-${topic_key}-${sub_key}" => {
          scope        = azurerm_eventgrid_domain_topic.this["${domain_key}-${topic_key}"].id
          subscription = sub
          name = coalesce(
            sub.name, sub_key
          )
        }
      }
    ]],
    # custom topic subscriptions
    [for topic_key, topic in var.eventgrid.custom_topics : {
      for sub_key, sub in topic.event_subscriptions :
      "${topic_key}-${sub_key}" => {
        scope        = azurerm_eventgrid_topic.this[topic_key].id
        subscription = sub
        name = coalesce(
          sub.name, sub_key
        )
      }
    }],
    # standalone subscriptions
    [{
      for key, sub in var.eventgrid.event_subscriptions : key => {
        scope        = sub.scope
        subscription = sub
        name = coalesce(
          sub.name, key
        )
      }
    }]
  ])...)

  name                                 = each.value.name
  scope                                = each.value.scope
  event_delivery_schema                = each.value.subscription.event_delivery_schema
  labels                               = each.value.subscription.labels
  expiration_time_utc                  = each.value.subscription.expiration_time_utc
  included_event_types                 = each.value.subscription.included_event_types
  advanced_filtering_on_arrays_enabled = each.value.subscription.advanced_filtering_on_arrays_enabled
  hybrid_connection_id                 = each.value.subscription.hybrid_connection_endpoint_id
  eventhub_id                          = each.value.subscription.eventhub_endpoint_id
  service_bus_queue_id                 = each.value.subscription.service_bus_queue_endpoint_id
  service_bus_topic_id                 = each.value.subscription.service_bus_topic_endpoint_id

  dynamic "dead_letter_identity" {
    for_each = each.value.subscription.dead_letter_identity != null ? { "this" = each.value.subscription.dead_letter_identity } : {}

    content {
      type                   = dead_letter_identity.value.type
      user_assigned_identity = dead_letter_identity.value.user_assigned_identity
    }
  }

  dynamic "delivery_identity" {
    for_each = each.value.subscription.delivery_identity != null ? { "this" = each.value.subscription.delivery_identity } : {}

    content {
      type                   = delivery_identity.value.type
      user_assigned_identity = delivery_identity.value.user_assigned_identity
    }
  }

  dynamic "storage_blob_dead_letter_destination" {
    for_each = each.value.subscription.storage_blob_dead_letter_destination != null ? { "this" = each.value.subscription.storage_blob_dead_letter_destination } : {}

    content {
      storage_account_id          = storage_blob_dead_letter_destination.value.storage_account_id
      storage_blob_container_name = storage_blob_dead_letter_destination.value.storage_blob_container_name
    }
  }

  dynamic "storage_queue_endpoint" {
    for_each = each.value.subscription.storage_queue_endpoint != null ? { "this" = each.value.subscription.storage_queue_endpoint } : {}

    content {
      storage_account_id                    = storage_queue_endpoint.value.storage_account_id
      queue_name                            = storage_queue_endpoint.value.queue_name
      queue_message_time_to_live_in_seconds = storage_queue_endpoint.value.queue_message_time_to_live_in_seconds
    }
  }

  dynamic "azure_function_endpoint" {
    for_each = each.value.subscription.azure_function_endpoint != null ? { "this" = each.value.subscription.azure_function_endpoint } : {}

    content {
      function_id                       = azure_function_endpoint.value.function_id
      max_events_per_batch              = azure_function_endpoint.value.max_events_per_batch
      preferred_batch_size_in_kilobytes = azure_function_endpoint.value.preferred_batch_size_in_kilobytes
    }
  }

  dynamic "webhook_endpoint" {
    for_each = each.value.subscription.webhook_endpoint != null ? { "this" = each.value.subscription.webhook_endpoint } : {}

    content {
      url                               = webhook_endpoint.value.url
      preferred_batch_size_in_kilobytes = webhook_endpoint.value.preferred_batch_size_in_kilobytes
      max_events_per_batch              = webhook_endpoint.value.max_events_per_batch
      active_directory_tenant_id        = webhook_endpoint.value.active_directory_tenant_id
      active_directory_app_id_or_uri    = webhook_endpoint.value.active_directory_app_id_or_uri
    }
  }

  dynamic "retry_policy" {
    for_each = each.value.subscription.retry_policy != null ? { "this" = each.value.subscription.retry_policy } : {}

    content {
      max_delivery_attempts = retry_policy.value.max_delivery_attempts
      event_time_to_live    = retry_policy.value.event_time_to_live
    }
  }

  dynamic "subject_filter" {
    for_each = each.value.subscription.subject_filter != null ? { "this" = each.value.subscription.subject_filter } : (
      each.value.subscription.filters != null ? { "this" = each.value.subscription.filters } : {}
    )

    content {
      subject_begins_with = subject_filter.value.subject_begins_with
      subject_ends_with   = subject_filter.value.subject_ends_with
      case_sensitive      = subject_filter.value.case_sensitive
    }
  }

  dynamic "advanced_filter" {
    for_each = each.value.subscription.advanced_filter != null ? { "this" = each.value.subscription.advanced_filter } : {}

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
    for_each = each.value.subscription.delivery_property_mappings

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
  for_each = var.eventgrid.system_topics

  name = coalesce(
    each.value.name, each.key
  )

  resource_group_name = coalesce(
    var.eventgrid.resource_group_name, var.resource_group_name
  )

  location = coalesce(
    var.eventgrid.location, var.location
  )

  source_resource_id = each.value.source_resource_id
  topic_type         = each.value.topic_type

  tags = coalesce(
    var.eventgrid.tags, var.tags
  )

  dynamic "identity" {
    for_each = each.value.identity != null ? { "this" = each.value.identity } : {}

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
}

# system topic event subscriptions
resource "azurerm_eventgrid_system_topic_event_subscription" "this" {
  for_each = merge(flatten([
    for topic_key, topic in var.eventgrid.system_topics : {
      for sub_key, sub in topic.event_subscriptions :
      "${topic_key}-${sub_key}" => merge(sub, {
        name       = coalesce(sub.name, sub_key)
        topic_name = azurerm_eventgrid_system_topic.this[topic_key].name
      })
    }
  ])...)

  name         = each.value.name
  system_topic = each.value.topic_name

  resource_group_name = coalesce(
    var.eventgrid.resource_group_name, var.resource_group_name
  )

  event_delivery_schema                = each.value.event_delivery_schema
  labels                               = each.value.labels
  expiration_time_utc                  = each.value.expiration_time_utc
  included_event_types                 = each.value.included_event_types
  advanced_filtering_on_arrays_enabled = each.value.advanced_filtering_on_arrays_enabled
  hybrid_connection_id                 = each.value.hybrid_connection_endpoint_id
  eventhub_id                          = each.value.eventhub_endpoint_id
  service_bus_queue_id                 = each.value.service_bus_queue_endpoint_id
  service_bus_topic_id                 = each.value.service_bus_topic_endpoint_id

  dynamic "storage_blob_dead_letter_destination" {
    for_each = each.value.storage_blob_dead_letter_destination != null ? { "this" = each.value.storage_blob_dead_letter_destination } : {}

    content {
      storage_account_id          = storage_blob_dead_letter_destination.value.storage_account_id
      storage_blob_container_name = storage_blob_dead_letter_destination.value.storage_blob_container_name
    }
  }

  dynamic "storage_queue_endpoint" {
    for_each = each.value.storage_queue_endpoint != null ? { "this" = each.value.storage_queue_endpoint } : {}

    content {
      storage_account_id                    = storage_queue_endpoint.value.storage_account_id
      queue_name                            = storage_queue_endpoint.value.queue_name
      queue_message_time_to_live_in_seconds = storage_queue_endpoint.value.queue_message_time_to_live_in_seconds
    }
  }

  dynamic "delivery_identity" {
    for_each = each.value.delivery_identity != null ? { "this" = each.value.delivery_identity } : {}

    content {
      type                   = delivery_identity.value.type
      user_assigned_identity = delivery_identity.value.user_assigned_identity
    }
  }

  dynamic "dead_letter_identity" {
    for_each = each.value.dead_letter_identity != null ? { "this" = each.value.dead_letter_identity } : {}

    content {
      type                   = dead_letter_identity.value.type
      user_assigned_identity = dead_letter_identity.value.user_assigned_identity
    }
  }

  dynamic "azure_function_endpoint" {
    for_each = each.value.azure_function_endpoint != null ? { "this" = each.value.azure_function_endpoint } : {}

    content {
      function_id                       = azure_function_endpoint.value.function_id
      max_events_per_batch              = azure_function_endpoint.value.max_events_per_batch
      preferred_batch_size_in_kilobytes = azure_function_endpoint.value.preferred_batch_size_in_kilobytes
    }
  }

  dynamic "webhook_endpoint" {
    for_each = each.value.webhook_endpoint != null ? { "this" = each.value.webhook_endpoint } : {}

    content {
      url                               = webhook_endpoint.value.url
      preferred_batch_size_in_kilobytes = webhook_endpoint.value.preferred_batch_size_in_kilobytes
      max_events_per_batch              = webhook_endpoint.value.max_events_per_batch
      active_directory_app_id_or_uri    = webhook_endpoint.value.active_directory_app_id_or_uri
      active_directory_tenant_id        = webhook_endpoint.value.active_directory_tenant_id
    }
  }

  dynamic "subject_filter" { //max 1
    for_each = each.value.subject_filter != null ? { "this" = each.value.subject_filter } : {}

    content {
      subject_begins_with = subject_filter.value.subject_begins_with
      subject_ends_with   = subject_filter.value.subject_ends_with
      case_sensitive      = subject_filter.value.case_sensitive
    }
  }

  dynamic "retry_policy" {
    for_each = each.value.retry_policy != null ? { "this" = each.value.retry_policy } : {}

    content {
      max_delivery_attempts = retry_policy.value.max_delivery_attempts
      event_time_to_live    = retry_policy.value.event_time_to_live
    }
  }

  dynamic "delivery_property" {
    for_each = each.value.delivery_property_mappings

    content {
      header_name  = delivery_property.value.header_name
      type         = delivery_property.value.type
      value        = delivery_property.value.value
      source_field = delivery_property.value.source_field
      secret       = delivery_property.value.secret
    }
  }

  dynamic "advanced_filter" {
    for_each = each.value.advanced_filter != null ? { "this" = each.value.advanced_filter } : {}

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
}

# custom topics
resource "azurerm_eventgrid_topic" "this" {
  for_each = var.eventgrid.custom_topics

  resource_group_name = coalesce(
    var.eventgrid.resource_group_name, var.resource_group_name
  )

  location = coalesce(
    var.eventgrid.location, var.location
  )

  name = coalesce(
    each.value.name, each.key
  )

  input_schema                  = each.value.input_schema
  public_network_access_enabled = each.value.public_network_access_enabled
  local_auth_enabled            = each.value.local_auth_enabled

  dynamic "inbound_ip_rule" {
    for_each = each.value.inbound_ip_rule

    content {
      ip_mask = inbound_ip_rule.value.ip_mask
      action  = inbound_ip_rule.value.action
    }
  }

  tags = coalesce(
    var.eventgrid.tags, var.tags
  )

  dynamic "identity" {
    for_each = each.value.identity != null ? { "this" = each.value.identity } : {}

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "input_mapping_fields" {
    for_each = each.value.input_mapping_fields != null ? { "this" = each.value.input_mapping_fields } : {}

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
    for_each = each.value.input_mapping_default_values != null ? { "this" = each.value.input_mapping_default_values } : {}

    content {
      data_version = input_mapping_default_values.value.data_version
      event_type   = input_mapping_default_values.value.event_type
      subject      = input_mapping_default_values.value.subject
    }
  }
}

