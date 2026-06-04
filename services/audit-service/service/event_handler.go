package service

import (
	"encoding/json"
	"net/http"

	"github.com/Dylar/ai-trust-game/services/audit-service/service/audit"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/network"
)

type EventHandler struct {
	sink audit.Sink
}

func NewEventHandler(sink audit.Sink) *EventHandler {
	if sink == nil {
		sink = audit.NewNoopSink()
	}
	return &EventHandler{sink: sink}
}

func (handler *EventHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	if req.Method != http.MethodPost {
		network.WriteJSONError(w, http.StatusMethodNotAllowed, network.ErrorCodeMethodNotAllowed)
		return
	}

	defer func() {
		_ = req.Body.Close()
	}()

	var event audit.Event
	if err := json.NewDecoder(req.Body).Decode(&event); err != nil {
		network.WriteJSONError(w, http.StatusBadRequest, network.ErrorCodeInvalidJSON)
		return
	}

	if err := handler.sink.WriteEvent(req.Context(), event); err != nil {
		network.WriteJSONError(w, http.StatusInternalServerError, network.ErrorCodeInternal)
		return
	}

	w.WriteHeader(http.StatusAccepted)
}
