package main

import (
	"encoding/csv"
	"html/template"
	"log"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", handler)

	log.Println("Web UI running on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func handler(w http.ResponseWriter, r *http.Request) {
	file, err := os.Open("data/curated/user_activity_summary.csv")
	if err != nil {
		http.Error(w, "ETL output not found", 500)
		return
	}
	defer file.Close()

	reader := csv.NewReader(file)
	rows, _ := reader.ReadAll()

	tmpl := `
<h2>User Activity Summary</h2>
<table border="1">
{{ range . }}
<tr>
  {{ range . }}
    <td>{{ . }}</td>
  {{ end }}
</tr>
{{ end }}
</table>
`

	t := template.Must(template.New("page").Parse(tmpl))
	t.Execute(w, rows)
}
