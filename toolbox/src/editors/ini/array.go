package ini

import (
	"errors"
	"os"
	"strconv"
	"strings"

	"github.com/samber/lo"
	"github.com/urfave/cli/v2"
)

var arrayCommand_value []string
var arrayCommand = cli.Command{
	Name:     "array",
	Usage:    "manager value of an array",
	Category: "typed item",
	Before: func(ctx *cli.Context) error {
		arrayCommand_value = iniKey.Strings(",")
		return nil
	},
	Subcommands: []*cli.Command{
		{
			Name:  "list",
			Usage: "print value line by line",
			Action: func(cCtx *cli.Context) error {
				os.Stdout.WriteString(strings.Join(arrayCommand_value, "\n"))
				return nil
			},
		},
		{
			Name:      "has",
			ArgsUsage: "<item> [...items]",
			Usage:     "test if it contains all provided values, return true of false in string",
			Action: func(cCtx *cli.Context) error {
				if !cCtx.Args().Present() {
					return errors.New("required at least one argument")
				}
				result := lo.Every(arrayCommand_value, cCtx.Args().Slice())
				os.Stdout.WriteString(strconv.FormatBool(result))
				return nil
			},
		},
		{
			Name:      "test",
			ArgsUsage: "<item> [...items]",
			Usage:     "same as 'has', but exit 1 when result is false",
			Action: func(cCtx *cli.Context) error {
				if !cCtx.Args().Present() {
					return errors.New("required at least one argument")
				}
				result := lo.Every(arrayCommand_value, cCtx.Args().Slice())
				if !result {
					os.Exit(1)
				}
				return nil
			},
		},
		{
			Name:      "push",
			ArgsUsage: "[...items]",
			Usage:     "push items to array end",
			Action: func(cCtx *cli.Context) error {
				arrayCommand_value = append(arrayCommand_value, cCtx.Args().Slice()...)
				iniKey.SetValue(strings.Join(arrayCommand_value, ","))
				return saveTargetFile()
			},
		},
		{
			Name:  "pop",
			Usage: "pop item to array end",
			Action: func(cCtx *cli.Context) error {
				len := len(arrayCommand_value)
				os.Stdout.WriteString(arrayCommand_value[len-1])
				arrayCommand_value = arrayCommand_value[:len-1]
				iniKey.SetValue(strings.Join(arrayCommand_value, ","))
				return saveTargetFile()
			},
		},
		{
			Name:      "unshift",
			ArgsUsage: "<item>",
			Usage:     "unshift item to array start",
			Action: func(cCtx *cli.Context) error {
				if cCtx.Args().Len() != 1 {
					return errors.New("required one argument only")
				}

				arrayCommand_value = append([]string{cCtx.Args().First()}, arrayCommand_value...)
				iniKey.SetValue(strings.Join(arrayCommand_value, ","))
				return saveTargetFile()
			},
		},
		{
			Name:  "shift",
			Usage: "shift item from array start",
			Action: func(cCtx *cli.Context) error {
				if cCtx.Args().Len() != 1 {
					return errors.New("required one argument only")
				}

				os.Stdout.WriteString(arrayCommand_value[0])
				arrayCommand_value = arrayCommand_value[1:]
				iniKey.SetValue(strings.Join(arrayCommand_value, ","))
				return saveTargetFile()
			},
		},
	},
}
