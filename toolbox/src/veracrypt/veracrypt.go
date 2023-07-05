package veracrypt

import (
	"github.com/urfave/cli/v2"
)

var Command = cli.Command{
	Name:  "veracrypt",
	Usage: "veracrypt helpers",
	Subcommands: []*cli.Command{
		&commandEnsure,
		&hiddenCommandEnsure,
		&backupCommand,
		&umountCommand,
	},
}
