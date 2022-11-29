package vault

import (
	"errors"
	"fmt"
	"reflect"
	"strings"

	"github.com/geektheripper/planetarian/toolbox/v2/src/utils"
	"github.com/itchyny/gojq"
	"github.com/samber/lo"
	"github.com/urfave/cli/v2"
)

// common
var secretFullPath string
var vaultPathFlag = cli.StringFlag{
	Name:        "path",
	Aliases:     []string{"p"},
	Usage:       "secret full path",
	Required:    true,
	Destination: &secretFullPath,
}

var formatName string
var formatFlag = cli.StringFlag{
	Name:        "format",
	Aliases:     []string{"f"},
	Usage:       "output format",
	Value:       "raw",
	Destination: &formatName,
}

var engineName string
var engineFlag = cli.StringFlag{
	Name:        "engine",
	Aliases:     []string{"e"},
	Usage:       "secrets engine, can be kv1, kv2, if engine not set, it will try all of them",
	Destination: &engineName,
}

var variableName string
var variableFlag = cli.StringFlag{
	Name:        "variable-name",
	Aliases:     []string{"vn"},
	Usage:       "variable name for output if necessary",
	Destination: &variableName,
}

var selectedKeysStr string
var selectedKeysFlag = cli.StringFlag{
	Name:        "selected-keys",
	Aliases:     []string{"sk"},
	Usage:       "select which to assign/export when assign/export a map",
	Destination: &selectedKeysStr,
}

var Command = cli.Command{
	Name:  "@vault",
	Usage: "vault utils for shell",
	Description: `format can be one of those:
raw         json string of object and array, or any basic type
              echo 1; echo '{"hello":"world"}';
assign      assign output to specific variable name
              VAR=hello;
export      same as above, but export
              export VAR=hello;
array       assign multiple output to specific variable name as array
              export VAR=("hello", "world");
assign-map  assign every pair key-value as variable, output should be a map
              Key1=Value1; Key2=Value2;
export-map  same as above, but export
              export Key1=Value1; export Key2=Value2;
`,
	Subcommands: []*cli.Command{
		&commandLogin,
		&commandSu,
		{
			Name: "jq",
			Flags: []cli.Flag{
				&vaultPathFlag,
				&engineFlag,
				&formatFlag,
				&variableFlag,
				&selectedKeysFlag,
			},
			Action: func(ctx *cli.Context) error {
				pQuery, err := gojq.Parse(ctx.Args().First())
				if err != nil {
					return nil
				}

				secret, err := GetSecret(ctx.Context, engineName, secretFullPath)
				if err != nil {
					return err
				}

				queryResults := []any{}
				appendResult := func(s any) error {
					if len(queryResults) > 1453 {
						return errors.New("too many queries")
					}
					queryResults = append(queryResults, s)
					return nil
				}

				iter := pQuery.RunWithContext(ctx.Context, secret.Data)
				for {
					queryResult, hasNext := iter.Next()
					if !hasNext {
						break
					}
					if err, ok := queryResult.(error); ok {
						return err
					}

					resultType := reflect.ValueOf(queryResult)

					switch formatName {
					case "assign":
						utils.ShellAssign(variableName, queryResult)
						return nil
					case "export":
						utils.ShellExport(variableName, queryResult)
						return nil
					case "assign-map", "export-map":
						if resultType.Kind() != reflect.Map {
							return errors.New("output should be a map (object)")
						}

						iter := resultType.MapRange()
						selectedKeysList := strings.Split(selectedKeysStr, ",")
						for iter.Next() {
							key, value := iter.Key(), iter.Value()

							if !lo.Contains(selectedKeysList, utils.ShellEscape(key)) {
								continue
							}

							if formatName == "assign-map" {
								utils.ShellAssign(key, value)
							} else {
								utils.ShellExport(key, value)
							}
						}
						return nil
					}

					appendResult(queryResult)
				}

				if formatName == "raw" {
					for _, v := range queryResults {
						utils.ShellEcho(v)
					}
				} else if formatName == "array" {
					utils.ShellAssignArray(variableName, queryResults)
				} else {
					return errors.New(fmt.Sprintf("invalid format: %s", formatName))
				}

				return nil
			},
		},
	},
}
