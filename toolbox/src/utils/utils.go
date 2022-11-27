package utils

import (
	"bufio"
	"io/fs"
	"log"
	"os"
	"strings"
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
