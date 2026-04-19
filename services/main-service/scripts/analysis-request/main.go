package main

import (
	"flag"
	"fmt"
	"net/http"

	scripts "github.com/Dylar/ai-trust-game/tooling/scripts"

	"github.com/Dylar/ai-trust-game/services/main-service/service"
)

const routePrefix = "/analysis/request/"

func main() {
	url := flag.String("url", scripts.BaseURL(), "base URL of the service")
	requestID := flag.String("request", "", "request id to inspect")
	flag.Parse()

	if *requestID == "" {
		panic("request id is required")
	}

	resp, err := scripts.DoJSONRequest(
		http.MethodGet,
		scripts.BuildURL(*url, routePrefix+*requestID),
		nil,
		nil,
	)
	scripts.PanicIfError(err, "can't send request")

	defer func() {
		scripts.PanicIfError(resp.Body.Close(), "can't close response body")
	}()

	var response service.RequestAnalysisResponse
	scripts.PanicIfError(
		scripts.DecodeJSONResponse(resp, &response),
		"can't decode response",
	)

	fmt.Println("Status:", resp.Status)
	fmt.Println("Request ID:", response.RequestID)
	fmt.Println("Classification:", response.Classification)
	fmt.Println("Signals:", response.Signals)
	fmt.Println("Attack Patterns:", response.AttackPatterns)
	fmt.Println("Event Count:", response.EventCount)
	fmt.Println("Suspicion Count:", response.SuspicionCount)
	fmt.Println("Model Fail Count:", response.ModelFailCount)
}
