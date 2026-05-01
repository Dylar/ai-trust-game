package assert

import (
	"errors"
	"testing"
)

func Equal[T comparable](t *testing.T, got, want T, assertFailedMsg string) {
	t.Helper()
	if got != want {
		t.Errorf("%s (got '%v', want '%v')", assertFailedMsg, got, want)
	}
}

func NotEqual[T comparable](t *testing.T, got, notWant T, assertFailedMsg string) {
	t.Helper()
	if got == notWant {
		t.Errorf("%s (got '%v', want '%v')", assertFailedMsg, got, notWant)
	}
}

func NotEmpty(t *testing.T, got string, assertFailedMsg string) {
	t.Helper()
	if got == "" {
		t.Errorf("%s (got empty string)", assertFailedMsg)
	}
}

func Empty(t *testing.T, got string, assertFailedMsg string) {
	t.Helper()
	if got != "" {
		t.Errorf("%s (got %s, expected empty string)", assertFailedMsg, got)
	}
}

func ErrorIs(t *testing.T, got error, want error, assertFailedMsg string) {
	t.Helper()
	if !errors.Is(got, want) {
		t.Errorf("%s (got '%v', want '%v')", assertFailedMsg, got, want)
	}
}
