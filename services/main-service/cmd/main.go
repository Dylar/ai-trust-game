package main

import (
	"github.com/Dylar/ai-trust-game/pkg/infra"
	"github.com/Dylar/ai-trust-game/services/main-service/service"
	"log"
)

func main() {
	srv := infra.NewServer(infra.Config{
		HTTP: []infra.HTTPConfig{
			{
				Name:     "main-service",
				Port:     infra.GetEnv("PORT", infra.DefaultPort),
				Register: service.RegisterRoutes,
			},
		},
	})

	err := srv.Run()
	if err != nil {
		log.Fatal(err)
	}
}
