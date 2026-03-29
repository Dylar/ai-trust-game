package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"net/http"

	"github.com/Dylar/ai-trust-game/internal/scripts"
	"github.com/Dylar/ai-trust-game/services/main-service/service"
)

const route = "/session/start"

func main() {
	url := flag.String("url", scripts.BaseURL(), "base URL of the service")
	role := flag.String("role", "customer", "role (customer | employee | admin)")
	mode := flag.String("mode", "easy", "mode (easy | medium | hard)")
	flag.Parse()

	reqBody := service.StartSessionRequest{
		Role: *role,
		Mode: *mode,
	}

	body, err := json.Marshal(reqBody)
	scripts.PanicIfError(err, "can't marshal request body")

	fullURL := *url + route

	resp, err := http.Post(fullURL, "application/json", bytes.NewBuffer(body))
	scripts.PanicIfError(err, "can't send request")

	defer func() {
		scripts.PanicIfError(resp.Body.Close(), "can't close response body")
	}()

	var response service.StartSessionResponse
	err = json.NewDecoder(resp.Body).Decode(&response)
	scripts.PanicIfError(err, "can't decode response")

	fmt.Println("Status:", resp.Status)
	fmt.Println("SessionID:", response.SessionID)
	fmt.Println("Role:", response.Role)
	fmt.Println("Mode:", response.Mode)
}
