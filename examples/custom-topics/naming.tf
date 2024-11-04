locals {
  naming = {
    # lookup outputs to have consistent naming
    for type in local.naming_types : type => lookup(module.naming, type).name
  }

  naming_types = ["servicebus_queue", "servicebus_queue_authorization_rule", "servicebus_topic", "servicebus_subscription", "eventgrid_domain_topic", "eventgrid_domain", "eventgrid_event_subscription", "eventgrid_topic"]
}
