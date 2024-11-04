output "domains" {
  description = "contains eventgrid domains configuration"
  value       = azurerm_eventgrid_domain.this
}

output "domain_topics" {
  description = "contains domain topics configuration"
  value       = azurerm_eventgrid_domain_topic.this
}

output "event_subscriptions" {
  description = "contains event subscriptions configuration"
  value       = azurerm_eventgrid_event_subscription.this
}

output "system_topics" {
  description = "contains system topics configuration"
  value       = azurerm_eventgrid_system_topic.this
}

output "system_topic_event_subscriptions" {
  description = "contains system topic event subscriptions configuration"
  value       = azurerm_eventgrid_system_topic_event_subscription.this
}

output "custom_topics" {
  description = "contains custom topics configuration"
  value       = azurerm_eventgrid_topic.this
}
