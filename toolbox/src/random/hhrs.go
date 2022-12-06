package random

import (
	"math/rand"
	"time"
)

const (
	VOWELS     = "aeiou"
	CONSONANTS = "bcdfghjklmnprstvwxyz"
)

var VOWELS_LENGTH = len(VOWELS)
var CONSONANTS_LENGTH = len(CONSONANTS)

func GetHumanReadableRandomString(length int) string {
	rand.Seed(time.Now().UnixNano())

	var randomString string
	salt := rand.Intn(2)

	for i := length + salt; i > 0+salt; i-- {
		if i%2 == 0 {
			randomString += string(CONSONANTS[rand.Intn(CONSONANTS_LENGTH)])
		} else {
			randomString += string(VOWELS[rand.Intn(VOWELS_LENGTH)])
		}
	}

	return randomString
}
