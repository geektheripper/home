package ini

import (
	"errors"
	"os"
	"strconv"
	"strings"

	mapset "github.com/deckarep/golang-set/v2"
	"github.com/urfave/cli/v2"
)

var setCommand_value mapset.Set[string]
var setCommand = cli.Command{
	Name:     "set",
	Usage:    "manager value of a set",
	Category: "typed item",
	Before: func(ctx *cli.Context) error {
		setCommand_value = mapset.NewSet(iniKey.Strings(",")...)
		return nil
	},
	Subcommands: []*cli.Command{
		{
			Name:  "list",
			Usage: "print value line by line",
			Action: func(cCtx *cli.Context) error {
				os.Stdout.WriteString(strings.Join(setCommand_value.ToSlice(), "\n"))
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
				result := setCommand_value.Contains(cCtx.Args().Slice()...)
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
				result := setCommand_value.Contains(cCtx.Args().Slice()...)
				if !result {
					os.Exit(1)
				}
				return nil
			},
		},
		{
			Name:      "add",
			ArgsUsage: "[...items]",
			Usage:     "add items into set",
			Action: func(cCtx *cli.Context) error {
				for _, v := range cCtx.Args().Slice() {
					setCommand_value.Add(v)
				}
				iniKey.SetValue(strings.Join(setCommand_value.ToSlice(), ","))
				return saveTargetFile()
			},
		},
		{
			Name:      "rm",
			ArgsUsage: "[...items]",
			Usage:     "remove items from set",
			Action: func(cCtx *cli.Context) error {
				for _, v := range cCtx.Args().Slice() {
					setCommand_value.Remove(v)
				}
				iniKey.SetValue(strings.Join(setCommand_value.ToSlice(), ","))
				return saveTargetFile()
			},
		},
	},
}
