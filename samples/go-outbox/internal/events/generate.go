package events

// To regenerate inventory_item_created.go from the canonical AVDL schema, run:
//
//  make gen-events
//
// Which performs two steps:
//  1. Compile AVDL → AVSC (requires Apache avro-tools JAR):
//       java -jar avro-tools.jar idl schema schemas/inventory_item_created.avdl schemas/inventory_item_created.avsc
//
//  2. Generate Go struct from AVSC (requires avrogen):
//       go install github.com/hamba/avro/v2/cmd/avrogen@latest
//       avrogen -pkg events -o internal/events/inventory_item_created.go -tags "json:snake" -strict-types schemas/inventory_item_created.avsc

//go:generate sh -c "java -jar avro-tools.jar idl schema schemas/inventory_item_created.avdl schemas/inventory_item_created.avsc && avrogen -pkg events -o internal/events/inventory_item_created.go -tags 'json:snake' -strict-types schemas/inventory_item_created.avsc"
