package main

import (
	"log"
	"os"

	"github.com/urfave/cli/v2"

	"github.com/geektheripper/planetarian/toolbox/v2/src/editors/ini"
	"github.com/geektheripper/planetarian/toolbox/v2/src/editors/text_block"
	"github.com/geektheripper/planetarian/toolbox/v2/src/json_util"
	"github.com/geektheripper/planetarian/toolbox/v2/src/random"
	"github.com/geektheripper/planetarian/toolbox/v2/src/tui"
	"github.com/geektheripper/planetarian/toolbox/v2/src/utils"
	"github.com/geektheripper/planetarian/toolbox/v2/src/vault"
	"github.com/geektheripper/planetarian/toolbox/v2/src/veracrypt"
)

func main() {
	app := &cli.App{}

	app.Name = "toolbox"
	app.Usage = "toolbox for shell works"
	app.Version = "alpha"
	app.Authors = []*cli.Author{
		{Name: "GeekTR", Email: "geektr@pm.me"},
	}

	app.EnableBashCompletion = true
	app.Writer = os.Stderr
	app.Commands = []*cli.Command{
		&ini.Command,
		&text_block.Command,
		&json_util.Command,
		&tui.Command,
		&vault.Command,
		&random.Command,
		&veracrypt.Command,
	}

	app.Commands = append(app.Commands, utils.UtilsCommands...)

	log.SetFlags(0)
	err := app.Run(os.Args)
	if err != nil {
		log.Fatal(err)
	}
}
