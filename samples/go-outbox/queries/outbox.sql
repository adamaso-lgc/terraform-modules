-- name: InsertOutboxEvent :one
INSERT INTO public.outbox (event_type, payload)
VALUES ($1, $2)
RETURNING *;
