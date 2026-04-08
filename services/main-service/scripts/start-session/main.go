package main

import (
	"flag"
	"fmt"
	scripts2 "github.com/Dylar/ai-trust-game/tooling/scripts"
	"net/http"

	"github.com/Dylar/ai-trust-game/services/main-service/service"
)

const route = "/session/start"

func main() {
	url := flag.String("url", scripts2.BaseURL(), "base URL of the service")
	role := flag.String("role", "guest", "role (guest | employee | admin)")
	mode := flag.String("mode", "easy", "mode (easy | medium | hard)")
	flag.Parse()

	reqBody := service.StartSessionRequest{
		Role: *role,
		Mode: *mode,
	}
	resp, err := scripts2.DoJSONRequest(
		http.MethodPost,
		scripts2.BuildURL(*url, route),
		reqBody,
		nil,
	)
	scripts2.PanicIfError(err, "can't send request")

	defer func() {
		scripts2.PanicIfError(resp.Body.Close(), "can't close response body")
	}()

	var response service.StartSessionResponse
	scripts2.PanicIfError(
		scripts2.DecodeJSONResponse(resp, &response),
		"can't decode response",
	)

	fmt.Println("Status:", resp.Status)
	fmt.Println("SessionID:", response.SessionID)
	fmt.Println("Role:", response.Role)
	fmt.Println("Mode:", response.Mode)
}
