locals {
  event_subscriptions = {
    blob-monitoring = {
      event_delivery_schema = "EventGridSchema"
      included_event_types = [
        "Microsoft.Storage.BlobCreated",
        "Microsoft.Storage.BlobDeleted"
      ]

      service_bus_queue_endpoint_id = module.servicebus.queues.storage_events.id

      subject_filter = {
        subject_begins_with = "/blobServices/default/containers/uploads"
        case_sensitive      = false
      }

      retry_policy = {
        max_delivery_attempts = 5
        event_time_to_live    = 1440
      }

      delivery_property_mappings = {
        container = {
          header_name  = "X-Container-Name"
          type         = "Dynamic"
          source_field = "data.containerName"
        }
        project = {
          header_name = "X-Project"
          type        = "Static"
          value       = "marketing"
        }
      }
    }
  }
}
