package tests

import (
	"errors"
	"testing"
)

// AssertEqual is a generic helper for comparing values
// t.Helper() ensures error messages point to the calling test, not the helper
func AssertEqual[T comparable](t *testing.T, got, want T, assertFailedMsg string) {
	t.Helper()
	if got != want {
		t.Errorf("%s (got '%v', want '%v')", assertFailedMsg, got, want)
	}
}

// AssertNotEqual is a generic helper for comparing values
// t.Helper() ensures error messages point to the calling test, not the helper
func AssertNotEqual[T comparable](t *testing.T, got, notWant T, assertFailedMsg string) {
	t.Helper()
	if got == notWant {
		t.Errorf("%s (got '%v', want '%v')", assertFailedMsg, got, notWant)
	}
}

// AssertNotEmpty is a helper for comparing values not empty
// t.Helper() ensures error messages point to the calling test, not the helper
func AssertNotEmpty(t *testing.T, got string, assertFailedMsg string) {
	t.Helper()
	if got == "" {
		t.Errorf("%s (got empty string)", assertFailedMsg)
	}
}

// AssertEmpty is a helper for comparing values not empty
// t.Helper() ensures error messages point to the calling test, not the helper
func AssertEmpty(t *testing.T, got string, assertFailedMsg string) {
	t.Helper()
	if got != "" {
		t.Errorf("%s (got %s, expected empty string)", assertFailedMsg, got)
	}
}

// AssertErrorIs is a helper for checking error conditions
func AssertErrorIs(t *testing.T, got error, want error, assertFailedMsg string) {
	t.Helper()
	if !errors.Is(got, want) {
		t.Errorf("%s (got '%v', want '%v')", assertFailedMsg, got, want)
	}
}
