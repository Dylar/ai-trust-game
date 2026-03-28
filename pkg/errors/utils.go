package errors

import "fmt"

func PanicIfError(err error, text string) {
	if err != nil {
		msg := fmt.Sprintf("%s : %v", text, err)
		panic(msg)
	}
}

func PanicIfErrorf(err error, text string, args ...any) {
	PanicIfError(err, fmt.Sprintf(text, args...))
}
