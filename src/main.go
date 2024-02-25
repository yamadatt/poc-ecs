package main

import (
	"fmt"
	"log"
	"net/http"
)

func handler(writer http.ResponseWriter, _ *http.Request) {
	fmt.Fprint(writer, "<h1>mount efs --- Hello World</h1>")
}

func main() {
	http.HandleFunc("/", handler)
	log.Fatal(http.ListenAndServe(":8091", nil))
}
