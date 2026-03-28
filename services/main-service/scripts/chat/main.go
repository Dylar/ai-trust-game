package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"net/http"

	"github.com/Dylar/ai-trust-game/pkg/errors"
	"github.com/Dylar/ai-trust-game/services/main-service/service"
)

const localURL = "http://localhost:8080"
const route = "/chat"

func main() {
	message := flag.String("message", "hello", "chat message")
	flag.Parse()

	reqBody := service.ChatRequest{
		Message: *message,
	}

	body, err := json.Marshal(reqBody)
	errors.PanicIfError(err, "can't marshal request body")

	url := localURL + route
	resp, err := http.Post(url, "application/json", bytes.NewBuffer(body))
	errors.PanicIfError(err, "can't send request")

	defer func() {
		errors.PanicIfError(resp.Body.Close(), "can't close response body")
	}()

	var response service.ChatResponse
	err = json.NewDecoder(resp.Body).Decode(&response)
	errors.PanicIfError(err, "can't decode response")

	fmt.Println("Status:", resp.Status)
	fmt.Println("Message:", response.Message)
}
