locals {
  event_subscriptions = {
    blob-created = {
      event_delivery_schema = "EventGridSchema"
      included_event_types = [
        "Microsoft.Storage.BlobCreated"
      ]

      service_bus_queue_endpoint_id = module.servicebus.queues.storage_events.id

      subject_filter = {
        subject_begins_with = "/blobServices/default/containers/uploads/"
      }

      retry_policy = {
        max_delivery_attempts = 5
        event_time_to_live    = 1440
      }
    }
  }
}
