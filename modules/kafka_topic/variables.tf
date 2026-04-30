variable "topic_name" {
  description = "Name of the Kafka topic. Use dot-separated naming for CDC topics (e.g. orders.public.outbox) or kebab-case for application topics."
  type        = string
}

variable "partitions" {
  description = "Number of partitions. Use 1 locally (single-node Redpanda). Use 3+ in production."
  type        = number
  default     = 1

  validation {
    condition     = var.partitions > 0
    error_message = "partitions must be a positive integer."
  }
}

variable "replication_factor" {
  description = "Replication factor. Must not exceed the number of broker nodes (1 locally with Redpanda)."
  type        = number
  default     = 1

  validation {
    condition     = var.replication_factor > 0
    error_message = "replication_factor must be a positive integer."
  }
}

variable "segment_bytes" {
  description = "The maximum size of a single log segment file before a new one is rolled. Default is 1 GiB."
  type        = number
  default     = 1073741824

  validation {
    condition     = var.segment_bytes > 0
    error_message = "segment_bytes must be positive."
  }
}

variable "segment_ms" {
  description = "Maximum time before a new log segment is rolled, in milliseconds. Default is 7 days."
  type        = number
  default     = 604800000

  validation {
    condition     = var.segment_ms > 0
    error_message = "segment_ms must be positive."
  }
}

variable "cleanup_policy" {
  description = "Log cleanup policy. Use 'delete' for event streams, 'compact' for changelog topics."
  type        = string
  default     = "delete"

  validation {
    condition     = contains(["delete", "compact"], var.cleanup_policy)
    error_message = "cleanup_policy must be one of: delete, compact."
  }
}

variable "retention_bytes" {
  description = "Maximum total size of log segments before old ones are discarded. -1 means unlimited."
  type        = number
  default     = -1

  validation {
    condition     = var.retention_bytes == -1 || var.retention_bytes > 0
    error_message = "retention_bytes must be positive or -1 (unlimited)."
  }
}

variable "retention_ms" {
  description = "Maximum time log segments are retained before being discarded, in milliseconds. -1 means unlimited."
  type        = number
  default     = -1

  validation {
    condition     = var.retention_ms == -1 || var.retention_ms > 0
    error_message = "retention_ms must be positive or -1 (unlimited)."
  }
}

variable "override_config" {
  description = "Additional topic configuration settings that override or extend the defaults."
  type        = map(string)
  default     = {}
}
