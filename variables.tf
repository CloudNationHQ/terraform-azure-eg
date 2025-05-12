variable "config" {
  description = "Contains all eventgrid configuration"
  type = object({
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
  validation {
    condition     = var.instance.location != null || var.location != null
    error_message = "location must be provided either in the config object or as a separate variable."
  }

  validation {
    condition     = var.instance.resource_group_name != null || var.resource_group_name != null
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
