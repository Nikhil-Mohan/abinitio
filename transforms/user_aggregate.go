package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"

	"gopkg.in/yaml.v3"
)

type Field struct {
	Name string `yaml:"name"`
	Type string `yaml:"type"`
}

type IO struct {
	Name   string  `yaml:"name"`
	Type   string  `yaml:"type"`
	Path   string  `yaml:"path"`
	Schema []Field `yaml:"schema"`
}

type Interface struct {
	Inputs  []IO `yaml:"inputs"`
	Outputs []IO `yaml:"outputs"`
}

func main() {
	// Load interface.yml
	interfaceFile := "graphs/user_flow/interface.yml"
	data, err := os.ReadFile(interfaceFile)
	if err != nil {
		log.Fatalf("Failed to read interface.yml: %v", err)
	}

	var contract Interface
	if err := yaml.Unmarshal(data, &contract); err != nil {
		log.Fatalf("Invalid interface.yml: %v", err)
	}

	if len(contract.Inputs) != 1 || len(contract.Outputs) != 1 {
		log.Fatalf("Invalid interface.yml: exactly one input and one output required")
	}

	input := contract.Inputs[0]
	output := contract.Outputs[0]

	// Open input
	file, err := os.Open(input.Path)
	if err != nil {
		log.Fatalf("Input file not found: %s", input.Path)
	}
	defer file.Close()

	reader := csv.NewReader(file)
	reader.TrimLeadingSpace = true
	reader.FieldsPerRecord = -1

	records, err := reader.ReadAll()
	if err != nil {
		log.Fatalf("Failed to read input CSV %s: %v", input.Path, err)
	}

	if len(records) < 2 {
		log.Fatalf("No data rows found in %s", input.Path)
	}

	// Header validation
	validateHeader(records[0], input.Schema)

	// Transformation
	counts := make(map[string]int)
	expectedCols := len(input.Schema)

	for i, row := range records {
		if i == 0 {
			continue
		}

		if len(row) != expectedCols {
			log.Fatalf(
				"Schema violation in %s at line %d: expected %d columns, got %d",
				input.Path, i+1, expectedCols, len(row),
			)
		}

		user := row[0]
		counts[user]++
	}

	// Prepare output
	if len(output.Schema) < 1 {
		log.Fatalf("Output schema must contain at least one field")
	}

	if err := os.MkdirAll("data/curated", 0755); err != nil {
		log.Fatalf("Failed to create output directory: %v", err)
	}

	out, err := os.Create(output.Path)
	if err != nil {
		log.Fatalf("Failed to create output file: %v", err)
	}
	defer out.Close()

	writer := csv.NewWriter(out)
	defer writer.Flush()

	writer.Write(schemaToHeader(output.Schema))
	for user, count := range counts {
		writer.Write([]string{user, fmt.Sprint(count)})
	}

	fmt.Printf(
		"[ETL] Processed %d records, produced %d aggregated rows\n",
		len(records)-1,
		len(counts),
	)
	fmt.Println("[ETL] Completed successfully")
}

func validateHeader(header []string, schema []Field) {
	if len(header) != len(schema) {
		log.Fatalf("Header length mismatch: expected %d, got %d", len(schema), len(header))
	}
	for i, field := range schema {
		if header[i] != field.Name {
			log.Fatalf("Header mismatch at position %d: expected %s, got %s", i+1, field.Name, header[i])
		}
	}
}

func schemaToHeader(schema []Field) []string {
	header := make([]string, len(schema))
	for i, field := range schema {
		header[i] = field.Name
	}
	return header
}
log.Printf(
	"[ETL] Validating input schema: CSV has %d columns, interface expects %d",
	len(records[0]), len(input.Schema),
  )
	if len(records[0]) != len(input.Schema) {
		log.Fatalf("Schema violation in %s: expected %d columns, got %d",
			input.Path, len(input.Schema), len(records[0]),
		)
	}  