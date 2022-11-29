package ini

import (
	"errors"
	"os"
	"strings"

	"github.com/geektheripper/planetarian/toolbox/v2/src/utils"
	"github.com/samber/lo"
	"github.com/urfave/cli/v2"
	"gopkg.in/ini.v1"
)

// flags
var targetStr string
var targetFile string
var targetSection string
var targetKey string

var defaultValue string

// public object
var iniFile *ini.File
var iniSection *ini.Section
var iniKey *ini.Key

func saveTargetFile() error {
	file, err := os.OpenFile(targetFile, os.O_CREATE|os.O_RDWR|os.O_TRUNC, 0644)
	if err != nil {
		return err
	}
	if _, err = iniFile.WriteTo(file); err != nil {
		return err
	}
	return file.Close()
}

var Command = cli.Command{
	Name:  "ini",
	Usage: "manage ini file content",
	UsageText: `toolbox ini -t path/to/file:section:key <command> [arguments...]
toolbox ini -f path/to/file -s section -k key <command> [arguments...]`,
	Category: "editor",
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:        "target",
			Aliases:     []string{"t"},
			Usage:       "specific following three flag in one line, like: ./test.ini:section:key",
			Destination: &targetStr,
		},
		&cli.StringFlag{
			Name:        "file",
			Aliases:     []string{"f"},
			Usage:       "target file",
			Destination: &targetFile,
		},
		&cli.StringFlag{
			Name:        "section",
			Aliases:     []string{"s"},
			Usage:       "target section",
			Destination: &targetSection,
		},
		&cli.StringFlag{
			Name:        "key",
			Aliases:     []string{"k"},
			Usage:       "target key",
			Destination: &targetKey,
		},
	},
	Before: func(cCtx *cli.Context) error {
		if lo.Contains(cCtx.LocalFlagNames(), "target") {
			target_parts := strings.Split(targetStr, ":")
			if len(target_parts) != 3 {
				return errors.New("illegal target: " + targetStr)
			}
			targetFile = target_parts[0]
			targetSection = target_parts[1]
			targetKey = target_parts[2]
		} else if !lo.Every(cCtx.LocalFlagNames(), []string{"file", "section", "key"}) {
			return errors.New("requires file, section, key, or combines them in target")
		}

		_, err := os.Stat(targetFile)
		file_exist := err != os.ErrNotExist
		if err != nil && err != os.ErrNotExist {
			return err
		}

		iniFile = lo.Ternary(file_exist, lo.Must(ini.Load(targetFile)), ini.Empty())
		iniSection = iniFile.Section(targetSection)
		iniKey = iniSection.Key(targetKey)
		return nil
	},
	Subcommands: []*cli.Command{
		{
			Name:  "read",
			Usage: "get value of a key",
			Flags: []cli.Flag{
				&cli.StringFlag{
					Name:        "default",
					Value:       "",
					Aliases:     []string{"d"},
					Usage:       "return this if there is no value",
					Destination: &defaultValue,
				},
			},
			Action: func(cCtx *cli.Context) error {
				value := iniKey.Value()
				if value == "" {
					value = defaultValue
				}
				os.Stdout.WriteString(value)
				return nil
			},
		},
		{
			Name:  "test",
			Usage: "test if value equals provided item, exit 1 if not",
			Action: func(cCtx *cli.Context) error {
				result := iniKey.Value() == cCtx.Args().First()
				if !result {
					os.Exit(1)
				}
				return nil
			},
		},
		{
			Name:      "write",
			ArgsUsage: "<value>",
			Usage:     "set value for key",
			Action: func(cCtx *cli.Context) error {
				value := lo.Switch[int, string](cCtx.Args().Len()).
					CaseF(0, func() string { return lo.Must(utils.StdinText()) }).
					CaseF(1, func() string { return cCtx.Args().Get(0) }).
					Default("")

				if lo.IsEmpty(value) {
					return errors.New("too many arguments")
				}

				iniKey.SetValue(value)
				return saveTargetFile()
			},
		},
		{
			Name:  "rm",
			Usage: "remove key in section",
			Action: func(cCtx *cli.Context) error {
				iniSection.DeleteKey(iniKey.Name())
				return saveTargetFile()
			},
		},
		&setCommand,
		&arrayCommand,
		&switchCommand,
	},
}
