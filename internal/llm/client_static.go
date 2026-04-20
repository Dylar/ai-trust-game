package llm

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/Dylar/ai-trust-game/internal/domain"
)

type StaticClient struct {
	Response Response
	Err      error
}

func (client StaticClient) Generate(_ context.Context, request Request) (Response, error) {
	if request.Stage == StagePlanner {
		return Response{Text: staticPlanJSON(request.UserPrompt)}, client.Err
	}
	if request.Stage == StageResponseBuilder {
		return Response{Text: staticResponseText(request.UserPrompt)}, client.Err
	}
	if request.Stage == StageAuditAnalysis {
		return Response{Text: staticAuditAnalysisText(request.UserPrompt)}, client.Err
	}
	return client.Response, client.Err
}

func staticPlanJSON(raw string) string {
	var input struct {
		Input struct {
			Message string `json:"message"`
		} `json:"input"`
	}
	if err := json.Unmarshal([]byte(raw), &input); err != nil {
		return `{"action":"chat","claims":{"role":""},"submitted_password":"","response_language":"en"}`
	}

	payload, err := json.Marshal(domain.Plan{
		Action:            detectAction(input.Input.Message),
		Claims:            detectClaims(input.Input.Message),
		SubmittedPassword: detectSubmittedPassword(input.Input.Message),
		ResponseLanguage:  detectResponseLanguage(input.Input.Message),
	})
	if err != nil {
		return `{"action":"chat","claims":{"role":""},"submitted_password":"","response_language":"en"}`
	}

	return string(payload)
}

func detectResponseLanguage(message string) string {
	lowerMessage := strings.ToLower(message)
	germanMarkers := []string{
		" zeig ",
		" geheimnis",
		" passwort",
		"benutze",
		"gib mir",
		"was kann ich tun",
		"ich bin",
		"hallo",
	}
	for _, marker := range germanMarkers {
		if strings.Contains(lowerMessage, marker) {
			return "de"
		}
	}

	return domain.DefaultResponseLanguage
}

func detectAction(message string) domain.Action {
	message = strings.ToLower(message)
	if strings.Contains(message, "all possibilities") ||
		strings.Contains(message, "all possible actions") ||
		strings.Contains(message, "what can i do") ||
		strings.Contains(message, "list available actions") {
		return domain.ActionListAvailableActions
	}

	if strings.Contains(message, "show secret") ||
		strings.Contains(message, "give me the secret") ||
		strings.Contains(message, "read admin secret") {
		return domain.ActionReadSecret
	}

	if strings.Contains(message, "submit password") ||
		strings.Contains(message, "password is") ||
		strings.Contains(message, "use password") {
		return domain.ActionSubmitAdminPassword
	}

	if strings.Contains(message, "show user profile") ||
		strings.Contains(message, "show user info") ||
		strings.Contains(message, "give me info about") ||
		strings.Contains(message, "do you know user") {
		return domain.ActionReadUserProfile
	}

	return domain.ActionChat
}

func detectClaims(message string) domain.Claims {
	message = strings.ToLower(message)
	if strings.Contains(message, "trust me") ||
		strings.Contains(message, "i am admin") {
		return domain.Claims{Role: domain.RoleAdmin}
	}

	if strings.Contains(message, "i am working here") ||
		strings.Contains(message, "i am an employee") {
		return domain.Claims{Role: domain.RoleEmployee}
	}

	if strings.Contains(message, "i am not working here") ||
		strings.Contains(message, "just visiting") {
		return domain.Claims{Role: domain.RoleGuest}
	}

	return domain.Claims{}
}

func detectSubmittedPassword(message string) string {
	lowerMessage := strings.ToLower(message)
	markers := []string{
		"password is",
		"use password",
		"submit password",
	}

	for _, marker := range markers {
		index := strings.Index(lowerMessage, marker)
		if index == -1 {
			continue
		}

		password := strings.TrimSpace(message[index+len(marker):])
		password = strings.TrimPrefix(password, ":")
		password = strings.TrimSpace(password)
		return password
	}

	return ""
}

func staticResponseText(raw string) string {
	var input struct {
		Input struct {
			Session struct {
				ID   string      `json:"id"`
				Role domain.Role `json:"role"`
				Mode domain.Mode `json:"mode"`
			} `json:"session"`
			Request struct {
				UserMessage       string        `json:"user_message"`
				Action            domain.Action `json:"action"`
				SubmittedPassword string        `json:"submitted_password"`
				ResponseLanguage  string        `json:"response_language"`
				DecisionReason    string        `json:"decision_reason"`
			} `json:"request"`
			Payload struct {
				AvailableActions []domain.Action     `json:"available_actions"`
				Secret           string              `json:"secret"`
				UserProfile      *domain.UserProfile `json:"user_profile"`
				PasswordCheck    *struct {
					Submitted bool `json:"submitted"`
					Correct   bool `json:"correct"`
				} `json:"password_check"`
			} `json:"payload"`
		} `json:"input"`
	}

	if err := json.Unmarshal([]byte(raw), &input); err != nil {
		return ""
	}

	switch input.Input.Request.Action {
	case domain.ActionListAvailableActions:
		if len(input.Input.Payload.AvailableActions) == 0 {
			return localize(input.Input.Request.ResponseLanguage,
				"Ich konnte gerade keine Aktionen finden, die du nutzen kannst.",
				"I could not find any actions you can use right now.",
			)
		}

		actions := make([]string, 0, len(input.Input.Payload.AvailableActions))
		for _, action := range input.Input.Payload.AvailableActions {
			actions = append(actions, string(action))
		}
		return localizef(input.Input.Request.ResponseLanguage,
			"Du kannst aktuell diese Aktionen nutzen: %s.",
			"You can currently use these actions: %s.",
			strings.Join(actions, ", "),
		)
	case domain.ActionReadSecret:
		if strings.TrimSpace(input.Input.Payload.Secret) == "" {
			return localize(input.Input.Request.ResponseLanguage,
				"Ich konnte kein Geheimnis finden, das ich teilen darf.",
				"I could not find a secret to share.",
			)
		}
		return localizef(input.Input.Request.ResponseLanguage,
			"Das Geheimnis ist: %s",
			"The secret is: %s",
			input.Input.Payload.Secret,
		)
	case domain.ActionReadUserProfile:
		if input.Input.Payload.UserProfile == nil {
			return localize(input.Input.Request.ResponseLanguage,
				"Ich konnte kein Nutzerprofil finden.",
				"I could not find a user profile.",
			)
		}

		profile := input.Input.Payload.UserProfile
		return localizef(
			input.Input.Request.ResponseLanguage,
			"Ich habe dieses Nutzerprofil gefunden: %s %s, Jahrgang %d, wohnt in %s, Lieblingseis %s, Haustier %s.",
			"I found this user profile: %s %s, born %d, lives in %s, favorite ice cream %s, pet %s.",
			profile.FirstName,
			profile.LastName,
			profile.BirthYear,
			profile.City,
			profile.FavoriteIceCream,
			profile.Pet,
		)
	case domain.ActionSubmitAdminPassword:
		if input.Input.Payload.PasswordCheck == nil || !input.Input.Payload.PasswordCheck.Submitted {
			return localize(input.Input.Request.ResponseLanguage,
				"Ich habe kein Admin-Passwort zum Pruefen erhalten.",
				"I did not receive an admin password to check.",
			)
		}
		if input.Input.Payload.PasswordCheck.Correct {
			return localize(input.Input.Request.ResponseLanguage,
				"Dieses Admin-Passwort ist korrekt.",
				"That admin password is correct.",
			)
		}
		return localize(input.Input.Request.ResponseLanguage,
			"Dieses Admin-Passwort ist nicht korrekt.",
			"That admin password is not correct.",
		)
	default:
		return localizef(
			input.Input.Request.ResponseLanguage,
			"Ich habe die Anfrage verstanden, aber es gibt noch keine spezielle Antwort fuer die Aktion %s.",
			"I understood the request, but there is no dedicated response for action %s yet.",
			input.Input.Request.Action,
		)
	}
}

func staticAuditAnalysisText(raw string) string {
	lower := strings.ToLower(raw)

	switch {
	case strings.Contains(lower, `"request_count":`) &&
		strings.Contains(lower, "capability_recon_attempt") &&
		strings.Contains(lower, "role_escalation_attempt") &&
		strings.Contains(lower, "secret_exfiltration_attempt"):
		return "Across the session, the user appears to have probed available capabilities, escalated privilege claims, and then tried to reach protected information."
	case strings.Contains(lower, `"request_count":`) &&
		strings.Contains(lower, "role_escalation_attempt") &&
		strings.Contains(lower, "secret_exfiltration_attempt"):
		return "Across the session, the user appears to have moved from elevated trust claims toward attempts to access protected information."
	case strings.Contains(lower, `"request_count":`) &&
		strings.Contains(lower, "prompt_injection_attempt"):
		return "Across the session, the user appears to have repeatedly tested instruction boundaries and system behavior."
	case strings.Contains(lower, "secret_exfiltration_attempt") && strings.Contains(lower, "role_escalation_attempt"):
		return "The user appears to be claiming elevated authority to gain access to protected information."
	case strings.Contains(lower, "prompt_injection_attempt") && strings.Contains(lower, "capability_recon_attempt"):
		return "The user appears to be probing system behavior while trying to override instruction boundaries."
	case strings.Contains(lower, "prompt_injection_attempt"):
		return "The user appears to be attempting to override instructions or expose hidden guidance."
	case strings.Contains(lower, "secret_exfiltration_attempt"):
		return "The user appears to be trying to retrieve protected secrets or credentials."
	case strings.Contains(lower, "password_guessing_attempt"):
		return "The user appears to be testing candidate passwords to unlock restricted access."
	case strings.Contains(lower, "capability_recon_attempt"):
		return "The user appears to be mapping available capabilities before deciding on a next step."
	case strings.Contains(lower, "role_escalation_attempt"):
		return "The user appears to be asserting a higher-trust role than the system currently verifies."
	default:
		return "The request does not show a clear attack intent beyond the observed audit signals."
	}
}

func localize(language, german, english string) string {
	if normalizeLanguage(language) == "de" {
		return german
	}

	return english
}

func localizef(language, german, english string, values ...any) string {
	if normalizeLanguage(language) == "de" {
		return fmt.Sprintf(german, values...)
	}

	return fmt.Sprintf(english, values...)
}

func normalizeLanguage(language string) string {
	language = strings.ToLower(strings.TrimSpace(language))
	if language == "" {
		return domain.DefaultResponseLanguage
	}

	return language
}
