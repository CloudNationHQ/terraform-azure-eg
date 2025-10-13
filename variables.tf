variable "config" {
  description = "Contains all eventgrid configuration"
  type = object({
    resource_group_name = optional(string)
    location            = optional(string)
    tags                = optional(map(string))
    input_schema                              = optional(string, "EventGridSchema")
    public_network_access_enabled             = optional(bool, true)
    auto_delete_topic_with_last_subscription  = optional(bool, false)
    local_auth_enabled                        = optional(bool, false)
    auto_create_topic_with_first_subscription = optional(bool, false)
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))
    domains = optional(map(object({
      name = optional(string)
      inbound_ip_rule = optional(list(object({
        ip_mask = string
        action  = optional(string, "Allow")
      })))
      input_mapping_default_values = optional(object({
        data_version = optional(string)
        event_type   = optional(string)
        subject      = optional(string)
      }))
      input_mapping_fields = optional(object({
        id           = optional(string)
        topic        = optional(string)
        subject      = optional(string)
        event_time   = optional(string)
        event_type   = optional(string)
        data_version = optional(string)
      }))
      domain_topics = optional(map(object({
        name = optional(string)
        event_subscriptions = optional(map(object({
          name                                 = optional(string)
          event_delivery_schema                = optional(string)
          included_event_types                 = optional(list(string))
          labels                               = optional(list(string))
          hybrid_connection_endpoint_id        = optional(string)
          advanced_filtering_on_arrays_enabled = optional(bool, false)
          expiration_time_utc                  = optional(string)
          service_bus_queue_endpoint_id        = optional(string)
          service_bus_topic_endpoint_id        = optional(string)
          eventhub_endpoint_id                 = optional(string)
          endpoint_type                        = optional(string)
          endpoint_id                          = optional(string)
          azure_function_endpoint = optional(object({
            function_id                       = string
            max_events_per_batch              = optional(number)
            preferred_batch_size_in_kilobytes = optional(number)
          }))
          webhook_endpoint = optional(object({
            url                               = string
            preferred_batch_size_in_kilobytes = optional(number)
            max_events_per_batch              = optional(number)
            active_directory_tenant_id        = optional(string)
            active_directory_app_id_or_uri    = optional(string)
          }))
          retry_policy = optional(object({
            max_delivery_attempts = number
            event_time_to_live    = number
          }))
          subject_filter = optional(object({
            subject_begins_with = optional(string, "/")
            subject_ends_with   = optional(string)
            case_sensitive      = optional(bool, false)
          }))
          filters = optional(object({
            subject_begins_with = optional(string, "/")
            subject_ends_with   = optional(string)
            case_sensitive      = optional(bool, false)
          }))
          advanced_filter = optional(object({
            bool_equals                   = optional(map(bool), {})
            is_not_null                   = optional(list(string), [])
            is_null_or_undefined          = optional(list(string), [])
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
            string_not_contains           = optional(map(list(string)), {})
            string_not_begins_with        = optional(map(list(string)), {})
            number_in_range               = optional(map(list(number)), {})
            number_not_in_range           = optional(map(list(number)), {})
          }))
          delivery_property_mappings = optional(map(object({
            header_name  = string
            type         = string
            value        = optional(string)
            source_field = optional(string)
            secret       = optional(string)
          })), {})
          dead_letter_identity = optional(object({
            type                   = string
            user_assigned_identity = optional(string)
          }))
          delivery_identity = optional(object({
            type                   = string
            user_assigned_identity = optional(string)
          }))
          storage_blob_dead_letter_destination = optional(object({
            storage_account_id          = string
            storage_blob_container_name = string
          }))
          storage_queue_endpoint = optional(object({
            storage_account_id                    = string
            queue_name                            = string
            queue_message_time_to_live_in_seconds = optional(number)
          }))
        })), {})
      })), {})
    })), {})
    custom_topics = optional(map(object({
      name                          = optional(string)
      input_schema                  = optional(string, "EventGridSchema")
      public_network_access_enabled = optional(bool, true)
      local_auth_enabled            = optional(bool, false)
      inbound_ip_rule = optional(list(object({
        ip_mask = string
        action  = optional(string, "Allow")
      })))
      identity = optional(object({
        type         = string
        identity_ids = optional(list(string))
      }))
      input_mapping_fields = optional(object({
        id           = optional(string)
        topic        = optional(string)
        subject      = optional(string)
        event_time   = optional(string)
        event_type   = optional(string)
        data_version = optional(string)
      }))
      input_mapping_default_values = optional(object({
        data_version = optional(string)
        event_type   = optional(string)
        subject      = optional(string)
      }))
      event_subscriptions = optional(map(object({
        name                                 = optional(string)
        event_delivery_schema                = optional(string)
        included_event_types                 = optional(list(string))
        labels                               = optional(list(string))
        hybrid_connection_endpoint_id        = optional(string)
        advanced_filtering_on_arrays_enabled = optional(bool, false)
        expiration_time_utc                  = optional(string)
        service_bus_queue_endpoint_id        = optional(string)
        service_bus_topic_endpoint_id        = optional(string)
        eventhub_endpoint_id                 = optional(string)
        endpoint_type                        = optional(string)
        endpoint_id                          = optional(string)
        azure_function_endpoint = optional(object({
          function_id                       = string
          max_events_per_batch              = optional(number)
          preferred_batch_size_in_kilobytes = optional(number)
        }))
        webhook_endpoint = optional(object({
          url                               = string
          preferred_batch_size_in_kilobytes = optional(number)
          max_events_per_batch              = optional(number)
          active_directory_tenant_id        = optional(string)
          active_directory_app_id_or_uri    = optional(string)
        }))
        retry_policy = optional(object({
          max_delivery_attempts = number
          event_time_to_live    = number
        }))
        subject_filter = optional(object({
          subject_begins_with = optional(string, "/")
          subject_ends_with   = optional(string)
          case_sensitive      = optional(bool, false)
        }))
        filters = optional(object({
          subject_begins_with = optional(string, "/")
          subject_ends_with   = optional(string)
          case_sensitive      = optional(bool, false)
        }))
        advanced_filter = optional(object({
          bool_equals                   = optional(map(bool), {})
          is_not_null                   = optional(list(string), [])
          is_null_or_undefined          = optional(list(string), [])
          number_greater_than           = optional(map(number), {})
          number_greater_than_or_equals = optional(map(number), {})
          number_less_than              = optional(map(number), {})
          number_less_than_or_equals    = optional(map(number), {})
          number_in_range               = optional(map(list(number)), {})
          number_not_in_range           = optional(map(list(number)), {})
          string_begins_with            = optional(map(list(string)), {})
          string_not_begins_with        = optional(map(list(string)), {})
          string_ends_with              = optional(map(list(string)), {})
          string_contains               = optional(map(list(string)), {})
          string_not_contains           = optional(map(list(string)), {})
          string_in                     = optional(map(list(string)), {})
          string_not_ends_with          = optional(map(list(string)), {})
          string_not_in                 = optional(map(list(string)), {})
          number_in                     = optional(map(list(number)), {})
          number_not_in                 = optional(map(list(number)), {})
        }))
        delivery_property_mappings = optional(map(object({
          header_name  = string
          type         = string
          value        = optional(string)
          source_field = optional(string)
          secret       = optional(string)
        })), {})
        dead_letter_identity = optional(object({
          type                   = string
          user_assigned_identity = optional(string)
        }))
        delivery_identity = optional(object({
          type                   = string
          user_assigned_identity = optional(string)
        }))
        storage_blob_dead_letter_destination = optional(object({
          storage_account_id          = string
          storage_blob_container_name = string
        }))
        storage_queue_endpoint = optional(object({
          storage_account_id                    = string
          queue_name                            = string
          queue_message_time_to_live_in_seconds = optional(number)
        }))
      })), {})
    })), {})
    system_topics = optional(map(object({
      name                   = optional(string)
      source_arm_resource_id = optional(string)
      source_resource_id     = optional(string)
      topic_type             = string
      identity = optional(object({
        type         = string
        identity_ids = optional(list(string))
      }))
      event_subscriptions = optional(map(object({
        name                                 = optional(string)
        included_event_types                 = optional(list(string), [])
        event_delivery_schema                = optional(string)
        service_bus_queue_endpoint_id        = optional(string)
        service_bus_topic_endpoint_id        = optional(string)
        eventhub_endpoint_id                 = optional(string)
        labels                               = optional(list(string), [])
        expiration_time_utc                  = optional(string)
        advanced_filtering_on_arrays_enabled = optional(bool, false)
        hybrid_connection_endpoint_id        = optional(string)
        delivery_property_mappings = optional(map(object({
          header_name  = string
          type         = string
          value        = optional(string)
          source_field = optional(string)
          secret       = optional(string)
        })), {})
        identity = optional(object({
          type         = string
          identity_ids = optional(list(string))
        }))
        storage_blob_dead_letter_destination = optional(object({
          storage_account_id          = string
          storage_blob_container_name = string
        }))
        storage_queue_endpoint = optional(object({
          storage_account_id                    = string
          queue_name                            = string
          queue_message_time_to_live_in_seconds = optional(number)
        }))
        delivery_identity = optional(object({
          type                   = string
          user_assigned_identity = optional(string)
        }))
        dead_letter_identity = optional(object({
          type                   = string
          user_assigned_identity = optional(string)
        }))
        azure_function_endpoint = optional(object({
          function_id                       = string
          max_events_per_batch              = optional(number)
          preferred_batch_size_in_kilobytes = optional(number)
        }))
        webhook_endpoint = optional(object({
          url                               = string
          preferred_batch_size_in_kilobytes = optional(number)
          max_events_per_batch              = optional(number)
          active_directory_app_id_or_uri    = optional(string)
          active_directory_tenant_id        = optional(string)
        }))
        subject_filter = optional(object({
          subject_begins_with = optional(string, "/")
          subject_ends_with   = optional(string)
          case_sensitive      = optional(bool, false)
        }))
        retry_policy = optional(object({
          max_delivery_attempts = number
          event_time_to_live    = number
        }))
        advanced_filter = optional(object({
          bool_equals                   = optional(map(bool), {})
          is_not_null                   = optional(list(string), [])
          is_null_or_undefined          = optional(list(string), [])
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
          string_not_contains           = optional(map(list(string)), {})
          string_not_begins_with        = optional(map(list(string)), {})
          number_in_range               = optional(map(list(number)), {})
          number_not_in_range           = optional(map(list(number)), {})
        }))
      })), {})
    })), {})
    event_subscriptions = optional(map(object({
      name                                 = optional(string)
      scope                                = string
      event_delivery_schema                = optional(string)
      included_event_types                 = optional(list(string))
      labels                               = optional(list(string))
      hybrid_connection_endpoint_id        = optional(string)
      advanced_filtering_on_arrays_enabled = optional(bool, false)
      expiration_time_utc                  = optional(string)
      service_bus_queue_endpoint_id        = optional(string)
      service_bus_topic_endpoint_id        = optional(string)
      eventhub_endpoint_id                 = optional(string)
      endpoint_type                        = optional(string)
      endpoint_id                          = optional(string)
      dead_letter_identity = optional(object({
        type                   = string
        user_assigned_identity = optional(string)
      }))
      storage_blob_dead_letter_destination = optional(object({
        storage_account_id          = string
        storage_blob_container_name = string
      }))
      storage_queue_endpoint = optional(object({
        storage_account_id                    = string
        queue_name                            = string
        queue_message_time_to_live_in_seconds = optional(number)
      }))
      delivery_identity = optional(object({
        type                   = string
        user_assigned_identity = optional(string)
      }))
      azure_function_endpoint = optional(object({
        function_id                       = string
        max_events_per_batch              = optional(number)
        preferred_batch_size_in_kilobytes = optional(number)
      }))
      webhook_endpoint = optional(object({
        url                               = string
        preferred_batch_size_in_kilobytes = optional(number)
        max_events_per_batch              = optional(number)
        active_directory_tenant_id        = optional(string)
        active_directory_app_id_or_uri    = optional(string)
      }))
      retry_policy = optional(object({
        max_delivery_attempts = number
        event_time_to_live    = number
      }))
      subject_filter = optional(object({
        subject_begins_with = optional(string, "/")
        subject_ends_with   = optional(string)
        case_sensitive      = optional(bool, false)
      }))
      filters = optional(object({
        subject_begins_with = optional(string, "/")
        subject_ends_with   = optional(string)
        case_sensitive      = optional(bool, false)
      }))
      advanced_filter = optional(object({
        bool_equals                   = optional(map(bool), {})
        is_not_null                   = optional(list(string), [])
        is_null_or_undefined          = optional(list(string), [])
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
        string_not_contains           = optional(map(list(string)), {})
        string_not_begins_with        = optional(map(list(string)), {})
        number_in_range               = optional(map(list(number)), {})
        number_not_in_range           = optional(map(list(number)), {})
      }))
      delivery_property_mappings = optional(map(object({
        header_name  = string
        type         = string
        value        = optional(string)
        source_field = optional(string)
        secret       = optional(string)
      })), {})
    })), {})
  })
  validation {
    condition     = var.config.location != null || var.location != null
    error_message = "location must be provided either in the config object or as a separate variable."
  }

  validation {
    condition     = var.config.resource_group_name != null || var.resource_group_name != null
    error_message = "resource group name must be provided either in the config object or as a separate variable."
  }
}

variable "naming" {
  description = "contains naming convention"
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
