package main

import (
	"github.com/Dylar/ai-trust-game/pkg/setup"
	"github.com/Dylar/ai-trust-game/services/main-service/service"
	"log"
)

func main() {
	srv := setup.NewServer(setup.Config{
		HTTP: []setup.HTTPConfig{
			{
				Name:     "main-service",
				Port:     setup.GetEnv("PORT", setup.DefaultPort),
				Register: service.RegisterRoutes,
			},
		},
	})

	err := srv.Run()
	if err != nil {
		log.Fatal(err)
	}
}
