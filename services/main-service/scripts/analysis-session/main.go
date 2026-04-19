package main

import (
	"flag"
	"fmt"
	"net/http"

	scripts "github.com/Dylar/ai-trust-game/tooling/scripts"

	"github.com/Dylar/ai-trust-game/services/main-service/service"
)

const routePrefix = "/analysis/session/"

func main() {
	url := flag.String("url", scripts.BaseURL(), "base URL of the service")
	sessionID := flag.String("session", "", "session id to inspect")
	flag.Parse()

	if *sessionID == "" {
		panic("session id is required")
	}

	resp, err := scripts.DoJSONRequest(
		http.MethodGet,
		scripts.BuildURL(*url, routePrefix+*sessionID),
		nil,
		nil,
	)
	scripts.PanicIfError(err, "can't send request")

	defer func() {
		scripts.PanicIfError(resp.Body.Close(), "can't close response body")
	}()

	var response service.SessionAnalysisResponse
	scripts.PanicIfError(
		scripts.DecodeJSONResponse(resp, &response),
		"can't decode response",
	)

	fmt.Println("Status:", resp.Status)
	fmt.Println("Session ID:", response.SessionID)
	fmt.Println("Classification:", response.Classification)
	fmt.Println("Signals:", response.Signals)
	fmt.Println("Request Count:", response.RequestCount)
	fmt.Println("Suspicion Count:", response.SuspicionCount)
	fmt.Println("Model Fail Count:", response.ModelFailCount)
	fmt.Println("Requests:")
	for _, request := range response.Requests {
		fmt.Printf("- %s | %s | signals=%v\n", request.RequestID, request.Classification, request.Signals)
	}
}
