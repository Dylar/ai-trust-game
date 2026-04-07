package interaction

type Source string

const (
	SourceSystem Source = "system"
	SourceLLM    Source = "llm"
)

type Decision struct {
	Allowed bool
	Reason  string
}

type Result struct {
	Message string

	Source Source
}
