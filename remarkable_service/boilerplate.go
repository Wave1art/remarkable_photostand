package main

import (
	"fmt"
)

var LOG_LEVEL = "error"

func check(err error, msg string) {
	if err != nil {
		// Don't panic on transient errors (network, parsing, etc.).
		// Print a helpful message and return so callers can handle failures
		// without crashing the whole service.
		if msg != "" {
			fmt.Println(msg)
		}
		fmt.Println(err)
	}
}

func debug(msg ...string) {
	if LOG_LEVEL == "debug" {
		fmt.Println(msg)
	}
}
