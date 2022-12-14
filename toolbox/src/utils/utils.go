package utils

import (
	"fmt"
	"os"

	"github.com/manifoldco/promptui"
	"github.com/samber/lo"
	"github.com/urfave/cli/v2"
	"gopkg.in/alessio/shellescape.v1"
)

var UtilsCommands = []*cli.Command{
	{
		Name:  "escape-cmd",
		Usage: "escape cmd to a bash string",
		Action: func(ctx *cli.Context) error {
			prompt := promptui.Prompt{
				Label:  "Input your command",
				Stdout: os.Stderr,
			}
			cmd := lo.Must(prompt.Run())
			fmt.Printf("%s", shellescape.Quote(cmd))
			return nil
		},
	},
}
