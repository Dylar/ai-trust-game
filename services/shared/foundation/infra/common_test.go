package infra

import "testing"

func TestGetEnvInt(t *testing.T) {
	type Given struct {
		value    string
		fallback int
	}

	type Then struct {
		expected int
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN integer env value " +
				"WHEN GetEnvInt is called " +
				"THEN returns parsed integer",
			given: Given{value: "9000", fallback: 5000},
			then:  Then{expected: 9000},
		},
		{
			name: "GIVEN invalid env value " +
				"WHEN GetEnvInt is called " +
				"THEN returns fallback",
			given: Given{value: "soon", fallback: 5000},
			then:  Then{expected: 5000},
		},
		{
			name: "GIVEN empty env value " +
				"WHEN GetEnvInt is called " +
				"THEN returns fallback",
			given: Given{fallback: 5000},
			then:  Then{expected: 5000},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			t.Setenv("TEST_INT_ENV", given.value)

			got := GetEnvInt("TEST_INT_ENV", given.fallback)

			if got != then.expected {
				t.Fatalf("expected %d, got %d", then.expected, got)
			}
		})
	}
}
