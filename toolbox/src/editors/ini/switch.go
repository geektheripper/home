package ini

import (
	"errors"
	"os"
	"strings"

	"github.com/samber/lo"
	"github.com/urfave/cli/v2"
)

var switchCommand_positive = []string{"true", "on", "yes"}
var switchCommand_negative = []string{"false", "off", "no"}
var switchCommand_status = append(switchCommand_positive, switchCommand_negative...)
var switchCommand_antonyms = map[string]string{
	"true":  "false",
	"false": "true",
	"on":    "off",
	"off":   "on",
	"yes":   "no",
	"no":    "yes",
}
var switchCommand_errorUnknownStatus = errors.New("switch value must be one of " + strings.Join(switchCommand_status, ", "))

var switchCommand = cli.Command{
	Name:     "switch",
	Usage:    "manager boolean value as on/off, yes/no, true/false",
	Category: "typed item",
	Subcommands: []*cli.Command{
		{
			Name:      "turn",
			Usage:     "turn to status",
			ArgsUsage: "<on|off|yes|no|true|false>",
			Action: func(cCtx *cli.Context) error {
				status := cCtx.Args().First()
				if !lo.Contains(switchCommand_status, status) {
					return switchCommand_errorUnknownStatus
				}
				iniKey.SetValue(status)
				saveTargetFile()
				return nil
			},
		},
		{
			Name:  "toggle",
			Usage: "toggle switch",
			Action: func(cCtx *cli.Context) error {
				status := iniKey.Value()
				if !lo.Contains(switchCommand_status, status) {
					return switchCommand_errorUnknownStatus
				}

				iniKey.SetValue(switchCommand_antonyms[status])
				return saveTargetFile()
			},
		},
		{
			Name:      "test",
			Usage:     "test if switch is in specific status",
			ArgsUsage: "<on|off|yes|no|true|false>",
			Action: func(cCtx *cli.Context) error {
				result := iniKey.Value() == cCtx.Args().First()
				if !result {
					os.Exit(1)
				}
				return nil
			},
		},
	},
}
