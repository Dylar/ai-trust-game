package domain

type Mode string

const (
	ModeEasy   Mode = "easy"
	ModeMedium Mode = "medium"
	ModeHard   Mode = "hard"
)

func ParseMode(input string) (Mode, bool) {
	switch Mode(input) {
	case ModeEasy,
		ModeMedium,
		ModeHard:
		return Mode(input), true
	default:
		return "", false
	}
}
