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

	input := contract.Inputs[0]
	output := contract.Outputs[0]

	// Validate input exists
	file, err := os.Open(input.Path)
	if err != nil {
		log.Fatalf("Input file not found: %s", input.Path)
	}
	defer file.Close()

	reader := csv.NewReader(file)
	records, err := reader.ReadAll()
	if err != nil {
		log.Fatalf("Failed to read input CSV")
	}

	// Schema validation (runtime)
	validateHeader(records[0], input.Schema)

	// Transformation logic
	counts := make(map[string]int)
	for i, row := range records {
		if i == 0 {
			continue
		}
		user := row[0]
		counts[user]++
	}

	// Prepare output
	os.MkdirAll("data/curated", 0755)
	out, err := os.Create(output.Path)
	if err != nil {
		log.Fatalf("Failed to create output file")
	}
	defer out.Close()

	writer := csv.NewWriter(out)
	writer.Write(schemaToHeader(output.Schema))

	for user, count := range counts {
		writer.Write([]string{user, fmt.Sprint(count)})
	}
	writer.Flush()

	fmt.Println("ETL completed successfully")
}
func validateHeader(header []string, schema []Field) {
	if len(header) != len(schema) {
		log.Fatalf("Header length mismatch")
	}
	for i, field := range schema {
		if header[i] != field.Name {
			log.Fatalf("Header mismatch: expected %s, got %s", field.Name, header[i])
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