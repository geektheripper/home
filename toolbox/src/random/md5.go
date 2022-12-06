package random

import (
	"crypto/md5"
	"crypto/rand"
	"fmt"
)

func GetSafeRandomMD5() []byte {
	randomBytes := make([]byte, 1453)
	rand.Read(randomBytes)
	hasher := md5.New()
	hasher.Write([]byte(randomBytes))
	return hasher.Sum(nil)
}

func GetSafeRandomMD5String() string {
	return fmt.Sprintf("%x", GetSafeRandomMD5())
}
