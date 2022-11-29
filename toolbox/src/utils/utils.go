package utils

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io/fs"
	"log"
	"os"
	"reflect"
	"strings"

	"gopkg.in/alessio/shellescape.v1"
)

func StdinLines() ([]string, error) {
	var lines []string
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}

	if scanner.Err() != nil {
		return nil, scanner.Err()
	}

	return lines, nil
}

func StdinText() (string, error) {
	lines, err := StdinLines()
	if err != nil {
		return "", err
	}
	return strings.Join(lines, "\n"), nil
}

func ReadFile(file string) (content string, rerr error) {
	bytes, err := os.ReadFile(file)
	if err != nil {
		rerr = err
	} else {
		content = string(bytes)
	}
	return
}

func WriteFile(file string, content string, mode fs.FileMode) error {
	fileInfo, err := os.Stat(file)
	if err != nil && err != os.ErrNotExist {
		return err
	}

	if mode == 0 {
		if err == nil {
			mode = fileInfo.Mode()
		} else {
			mode = 0644
		}
	}

	os.WriteFile(file, []byte(content), mode)
	return nil
}

func TrimJoin(elems []string, cutset string, sep string) string {
	for index, e := range elems {
		if index == 0 {
			elems[index] = strings.TrimRight(e, cutset)
		} else if index == len(e)-1 {
			elems[index] = strings.TrimLeft(e, cutset)
		} else {
			elems[index] = strings.Trim(e, cutset)
		}
	}
	return strings.Join(elems, sep)
}

func TrimJoinLines(elems ...string) string {
	return TrimJoin(elems, "\n", "\n\n")
}

var ErrLog *log.Logger = log.New(os.Stderr, "", 0)

func ShellEscape(s interface{}) string {
	resultType := reflect.ValueOf(s)

	switch resultType.Kind() {
	case reflect.Map, reflect.Slice:
		byte, err := json.Marshal(s)
		if err != nil {
			panic(err)
		}
		return shellescape.Quote(string(byte))
	default:
		return shellescape.Quote(fmt.Sprint(s))
	}
}
func ShellEcho(msg any)        { fmt.Printf("echo %s;\n", ShellEscape(msg)) }
func ShellAssign(k any, v any) { fmt.Printf("%s=%s;\n", ShellEscape(k), ShellEscape(v)) }
func ShellExport(k any, v any) { fmt.Printf("export %s=%s;\n", ShellEscape(k), ShellEscape(v)) }
func ShellAssignArray(k any, v []any) {
	result := []string{}
	for _, value := range v {
		result = append(result, ShellEscape(value))
	}
	fmt.Printf("%s=(%s);", k, strings.Join(result, " "))
}

func MustGetEnv(key string) string {
	result := os.Getenv(key)
	if result == "" {
		ErrLog.Fatalf("Error: require environment: %s", key)
	}
	return result
}

func DefaultsEnv(key string, defaultValue string) string {
	result := os.Getenv(key)
	if result == "" {
		return defaultValue
	}
	return result
}

func MustReadFile(name string) string {
	content, err := os.ReadFile(name)
	if err != nil {
		ErrLog.Fatalf("Error: read %s failed, %s", name, err)
	}
	return string(content)
}
