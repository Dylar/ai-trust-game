package planning

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/llm"
)

type Planner struct {
	client llm.Client
}

func NewStaticPlanner() Planner {
	return NewPlanner(llm.StaticClient{})
}

func NewPlanner(client llm.Client) Planner {
	return Planner{client: client}
}

func (planner Planner) Plan(ctx context.Context, message string) (domain.Plan, error) {
	response, err := planner.client.Generate(ctx, buildPrompt(message))
	if err != nil {
		return domain.Plan{}, err
	}

	return parsePlan(response.Text)
}

func parsePlan(raw string) (domain.Plan, error) {
	var plan domain.Plan
	if err := json.Unmarshal([]byte(raw), &plan); err != nil {
		return domain.Plan{}, OutputError{
			Cause:     fmt.Errorf("parse planner response json: %w", err),
			RawOutput: raw,
		}
	}

	action, err := domain.ParseAction(plan.Action)
	if err != nil {
		return domain.Plan{}, OutputError{
			Cause:     err,
			RawOutput: raw,
		}
	}

	claims, err := parseClaimsRole(plan.Claims.Role)
	if err != nil {
		return domain.Plan{}, OutputError{
			Cause:     err,
			RawOutput: raw,
		}
	}

	plan.Action = action
	plan.Claims = claims
	plan.ResponseLanguage = parseResponseLanguage(plan.ResponseLanguage)
	return plan, nil
}

func parseClaimsRole(input domain.Role) (domain.Claims, error) {
	if input == "" {
		return domain.Claims{}, nil
	}

	role, ok := domain.ParseRole(string(input))
	if !ok {
		return domain.Claims{}, fmt.Errorf("unknown planner role %q", input)
	}

	return domain.Claims{Role: role}, nil
}

func parseResponseLanguage(input string) string {
	language := strings.ToLower(strings.TrimSpace(input))
	if language == "" {
		return domain.DefaultResponseLanguage
	}

	return language
}
