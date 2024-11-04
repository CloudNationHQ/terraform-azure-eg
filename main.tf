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
  tags                = try(var.config.tags, var.tags, null)
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
            name         = try(sub.name, join("-", [var.naming.eventgrid_event_subscription, sub_key]))
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
            name         = try(sub.name, join("-", [var.naming.eventgrid_event_subscription, sub_key]))
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

  name                  = each.value.name
  scope                 = each.value.scope
  event_delivery_schema = try(each.value.subscription.event_delivery_schema, null)
  included_event_types  = try(each.value.subscription.included_event_types, null)
  labels                = try(each.value.subscription.labels, null)

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

  dynamic "webhook_endpoint" {
    for_each = lookup(each.value.subscription, "endpoint_type", null) == "webhook" ? [1] : []
    content {
      url = lookup(each.value.subscription, "endpoint_url", null)
    }
  }

  dynamic "retry_policy" {
    for_each = lookup(each.value.subscription, "retry_policy", null) != null ? [lookup(each.value.subscription, "retry_policy", null)] : []
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
    for_each = lookup(each.value.subscription, "advanced_filter", null) != null ? [lookup(each.value.subscription, "advanced_filter", null)] : []

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
        for_each = lookup(advanced_filter.value, "number_greater_than", {})
        content {
          key   = number_greater_than.key
          value = number_greater_than.value
        }
      }
      dynamic "number_greater_than_or_equals" {
        for_each = lookup(advanced_filter.value, "number_greater_than_or_equals", {})
        content {
          key   = number_greater_than_or_equals.key
          value = number_greater_than_or_equals.value
        }
      }
      dynamic "number_less_than" {
        for_each = lookup(advanced_filter.value, "number_less_than", {})
        content {
          key   = number_less_than.key
          value = number_less_than.value
        }
      }
      dynamic "number_less_than_or_equals" {
        for_each = lookup(advanced_filter.value, "number_less_than_or_equals", {})
        content {
          key   = number_less_than_or_equals.key
          value = number_less_than_or_equals.value
        }
      }
      dynamic "number_in" {
        for_each = lookup(advanced_filter.value, "number_in", {})
        content {
          key    = number_in.key
          values = number_in.value
        }
      }
      dynamic "number_not_in" {
        for_each = lookup(advanced_filter.value, "number_not_in", {})
        content {
          key    = number_not_in.key
          values = number_not_in.value
        }
      }
      dynamic "string_begins_with" {
        for_each = lookup(advanced_filter.value, "string_begins_with", {})
        content {
          key    = string_begins_with.key
          values = string_begins_with.value
        }
      }
      dynamic "string_ends_with" {
        for_each = lookup(advanced_filter.value, "string_ends_with", {})
        content {
          key    = string_ends_with.key
          values = string_ends_with.value
        }
      }
      dynamic "string_contains" {
        for_each = lookup(advanced_filter.value, "string_contains", {})
        content {
          key    = string_contains.key
          values = string_contains.value
        }
      }
      dynamic "string_in" {
        for_each = lookup(advanced_filter.value, "string_in", {})
        content {
          key    = string_in.key
          values = string_in.value
        }
      }
      dynamic "string_not_in" {
        for_each = lookup(advanced_filter.value, "string_not_in", {})
        content {
          key    = string_not_in.key
          values = string_not_in.value
        }
      }
    }
  }

  dynamic "delivery_property" {
    for_each = lookup(each.value.subscription, "delivery_property_mappings", {})
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

  name                   = "${var.config.name}-${each.key}"
  resource_group_name    = coalesce(lookup(var.config, "resource_group", null), var.resource_group)
  location               = coalesce(lookup(var.config, "location", null), var.location)
  source_arm_resource_id = each.value.source_arm_resource_id
  topic_type             = each.value.topic_type
  tags                   = try(var.config.tags, var.tags, null)
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
          included_event_types          = sub.included_event_types
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

  event_delivery_schema         = each.value.event_delivery_schema
  included_event_types          = each.value.included_event_types
  service_bus_queue_endpoint_id = each.value.service_bus_queue_endpoint_id
  service_bus_topic_endpoint_id = each.value.service_bus_topic_endpoint_id
  eventhub_endpoint_id          = each.value.eventhub_endpoint_id

  dynamic "webhook_endpoint" {
    for_each = each.value.webhook_endpoint != null ? [each.value.webhook_endpoint] : []
    content {
      url = webhook_endpoint.value.url
    }
  }

  dynamic "subject_filter" {
    for_each = each.value.subject_filter != null ? [each.value.subject_filter] : []
    content {
      subject_begins_with = lookup(subject_filter.value, "subject_begins_with", "/")
      subject_ends_with   = lookup(subject_filter.value, "subject_ends_with", null)
      case_sensitive      = lookup(subject_filter.value, "case_sensitive", false)
    }
  }

  dynamic "retry_policy" {
    for_each = each.value.retry_policy != null ? [each.value.retry_policy] : []
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
  input_schema                  = each.value.input_schema
  public_network_access_enabled = each.value.public_network_access_enabled
  local_auth_enabled            = try(each.value.local_auth_enabled, false)
  tags                          = try(var.config.tags, var.tags, null)
}
