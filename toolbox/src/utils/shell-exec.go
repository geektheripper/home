package utils

import (
	"encoding/json"
	"fmt"
	"os"
	"reflect"
	"strings"

	"github.com/samber/lo"
	"gopkg.in/alessio/shellescape.v1"
)

type ShellExec struct {
	echo   []string
	assign [][]string
	export [][]string
}

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

func (se *ShellExec) Echo(msg any) *ShellExec {
	se.echo = append(se.echo, ShellEscape(msg))
	return se
}

func (se *ShellExec) Assign(k any, v any) *ShellExec {
	se.assign = append(se.assign, []string{ShellEscape(k), ShellEscape(v)})
	return se
}

func (se *ShellExec) Export(k any, v any) *ShellExec {
	se.export = append(se.export, []string{ShellEscape(k), ShellEscape(v)})
	return se
}

func (se *ShellExec) AssignArray(k any, v []any) *ShellExec {
	result := []string{}
	for _, value := range v {
		result = append(result, ShellEscape(value))
	}
	se.assign = append(se.assign, []string{ShellEscape(k), fmt.Sprintf("(%s)", strings.Join(result, " "))})
	return se
}

func (se *ShellExec) GenScript() string {
	lines := []string{}
	if len(se.echo) > 0 {
		lines = append(lines, fmt.Sprintf("echo %s", ShellEscape(strings.Join(se.echo, "\n"))))
	}
	if len(se.assign) > 0 {
		line := strings.Join(
			lo.Map(se.assign, func(v []string, i int) string { return fmt.Sprintf("%s=%s", v[0], v[1]) }),
			" ",
		)

		lines = append(lines, line)
	}
	if len(se.export) > 0 {
		line := "export "
		line += strings.Join(
			lo.Map(se.export, func(v []string, i int) string { return fmt.Sprintf("%s=%s", v[0], v[1]) }),
			" ",
		)
		lines = append(lines, line)
	}
	return strings.Join(lines, "\n")
}

func (se *ShellExec) PrintScript() error { os.Stdout.WriteString(se.GenScript()); return nil }
