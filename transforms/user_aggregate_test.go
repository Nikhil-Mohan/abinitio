package main

import "testing"

func TestSchemaToHeader(t *testing.T) {
	schema := []Field{
		{Name: "user_id", Type: "string"},
		{Name: "event_count", Type: "int"},
	}

	header := schemaToHeader(schema)

	if len(header) != 2 {
		t.Fatalf("Expected 2 headers, got %d", len(header))
	}
	if header[0] != "user_id" {
		t.Fatalf("Unexpected header name")
	}
}

func TestValidateHeader(t *testing.T) {
	header := []string{"user_id", "event_count"}
	schema := []Field{
		{Name: "user_id", Type: "string"},
		{Name: "event_count", Type: "int"},
	}

	// Should not panic
	validateHeader(header, schema)
}
