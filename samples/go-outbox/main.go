package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/jackc/pgx/v5"

	"go-outbox/internal/db"
	"go-outbox/internal/events"
)

func main() {
	connStr := buildConnStr()

	ctx := context.Background()
	conn, err := pgx.Connect(ctx, connStr)
	if err != nil {
		log.Fatalf("connect: %v", err)
	}
	defer conn.Close(ctx)

	queries := db.New(conn)

	evt := events.InventoryItemCreated{
		ItemID:    "item-001",
		Name:      "Widget A",
		Quantity:  100,
		CreatedAt: time.Now().UTC().Format(time.RFC3339),
	}

	payload, err := json.Marshal(evt)
	if err != nil {
		log.Fatalf("marshal payload: %v", err)
	}

	outboxEvent, err := queries.InsertOutboxEvent(ctx, db.InsertOutboxEventParams{
		EventType: "inventory.item.created",
		Payload:   payload,
	})
	if err != nil {
		log.Fatalf("insert event: %v", err)
	}

	b := outboxEvent.ID.Bytes
	id := fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:16])
	fmt.Printf("inserted outbox event id=%s type=%s\n", id, outboxEvent.EventType)
}

func buildConnStr() string {
	host := envOrDefault("OUTBOX_DB_HOST", "localhost")
	port := envOrDefault("OUTBOX_DB_PORT", "5432")
	dbname := envOrDefault("OUTBOX_DB_NAME", "inventory")
	user := envOrDefault("OUTBOX_DB_USER", "inventory_user")
	password := envOrDefault("OUTBOX_DB_PASSWORD", "inventory_local_secret")
	return fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable", user, password, host, port, dbname)
}

func envOrDefault(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
