package utils

import (
	"bufio"
	"errors"
	"io/fs"
	"log"
	"os"
	"path"
	"regexp"
	"strings"

	"github.com/go-playground/validator/v10"
	"github.com/manifoldco/promptui"
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

func ReadInput(label string, inputType string, defaultValue string, isSecret bool) string {
	var vldt *validator.Validate
	var re *regexp.Regexp

	if inputType != "" {
		vldt = validator.New()
		re, _ = regexp.Compile("^Key: '' Error:Field validation for '' failed on the '(.+)?' tag$")
	}

	validate := func(s string) error {
		err := vldt.Var(s, inputType)
		if err == nil {
			return nil
		}
		tagName := re.FindSubmatch([]byte(err.Error()))
		return errors.New("input mismatch '" + string(tagName[1]) + "' tag")
	}

	prompt := promptui.Prompt{
		Validate: validate,
		Label:    label,
		Stdout:   os.Stderr,
		Default:  defaultValue,
	}

	if isSecret {
		prompt.Mask = '*'
		prompt.HideEntered = true
	}

	result, err := prompt.Run()

	if err != nil {
		ErrLog.Fatalf("Prompt failed %v\n", err)
		return ""
	}

	return result
}

func FindProjectRootDir() (string, error) {
	dir, err := os.Getwd()
	if err != nil {
		return "", err
	}

	for {
		if _, err := os.Stat(path.Join(dir, ".git")); err == nil {
			return dir, nil
		}
		dir = dir[:strings.LastIndex(dir, "/")]
		if dir == "" {
			return "", errors.New("not found .git")
		}
	}
}
