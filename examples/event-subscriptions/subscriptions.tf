locals {
  event_subscriptions = {
    storage-events = {
      scope                 = module.storage.account.id
      event_delivery_schema = "EventGridSchema"
      included_event_types  = ["Microsoft.Storage.BlobCreated"]

      service_bus_queue_endpoint_id = module.servicebus.queues.storage.id

      subject_filter = {
        subject_begins_with = "/blobServices/default/containers/uploads"
        case_sensitive      = false
      }

      advanced_filter = {
        number_greater_than = {
          "data.contentLength" = 5242880
        }
        string_in = {
          "data.contentType" = [
            "application/pdf",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
          ]
        }
        string_begins_with = {
          "data.metadata.department" = ["marketing", "sales"]
        }
      }

      retry_policy = {
        max_delivery_attempts = 5
        event_time_to_live    = 1440
      }
    }
  }
}
