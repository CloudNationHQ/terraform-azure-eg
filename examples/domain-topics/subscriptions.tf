locals {
  event_subscriptions = {
    order-processing = {
      event_delivery_schema         = "EventGridSchema"
      included_event_types          = ["OrderCreated", "OrderUpdated"]
      service_bus_queue_endpoint_id = module.servicebus.queues.orders.id
      labels                        = ["orders", "processing"]

      retry_policy = {
        max_delivery_attempts = 5
        event_time_to_live    = 1440
      }

      subject_filter = {
        subject_begins_with = "/orders/"
        case_sensitive      = false
      }
      delivery_property_mappings = {
        order_source = {
          header_name = "X-Order-Source"
          type        = "Static"
          value       = "event-grid"
        }
        order_id = {
          header_name  = "X-Order-Id"
          type         = "Dynamic"
          source_field = "data.orderId"
        }
      }
    }
  }
}
