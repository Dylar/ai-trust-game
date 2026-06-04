package planning

import "fmt"

type OutputError struct {
	Cause     error
	RawOutput string
}

func (err OutputError) Error() string {
	if err.Cause == nil {
		return "planner output error"
	}

	return fmt.Sprintf("planner output error: %v", err.Cause)
}

func (err OutputError) Unwrap() error {
	return err.Cause
}
