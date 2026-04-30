terraform {
  required_providers {
    kafka = {
      source = "Mongey/kafka"
    }
  }
}

resource "kafka_topic" "topic" {
  name               = var.topic_name
  replication_factor = var.replication_factor
  partitions         = var.partitions

  config = merge(
    {
      "segment.bytes"  = tostring(var.segment_bytes)
      "segment.ms"     = tostring(var.segment_ms)
      "cleanup.policy" = var.cleanup_policy
      "retention.bytes" = tostring(var.retention_bytes)
      "retention.ms"   = tostring(var.retention_ms)
    },
    var.override_config
  )
}

output "topic_name" {
  description = "Name of the created Kafka topic."
  value       = kafka_topic.topic.name
}
