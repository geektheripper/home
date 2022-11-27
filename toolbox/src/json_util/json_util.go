package json_util

import (
	"os"

	"github.com/geektheripper/planetarian/toolbox/v2/src/utils"
	"github.com/robertkrimen/otto"
	"github.com/samber/lo"
	"github.com/urfave/cli/v2"
)

var data string

var flags = []cli.Flag{
	&cli.StringFlag{
		Name:        "data",
		Aliases:     []string{"d"},
		Usage:       "json string",
		Destination: &data,
	},
}

var Command = cli.Command{
	Name:    "json-util",
	Aliases: []string{"ju"},
	Usage:   "run javascript to process json",
	Subcommands: []*cli.Command{
		{
			Name:        "query",
			Flags:       flags,
			Usage:       "query value in json using javascript",
			Description: `query --data '{"a":1}' 'd.a'`,
			Action: func(cCtx *cli.Context) error {
				if data == "" || data == "-" {
					data = lo.Must(utils.StdinText())
				}

				script := cCtx.Args().Get(0)

				vm := otto.New()
				vm.Set("data", data)

				result, err := vm.Run(`(function(d) { return ` + script + `; })(JSON.parse(data))`)
				if err != nil {
					return err
				}

				os.Stdout.Write([]byte(lo.Must(result.ToString())))
				return nil
			},
		},
	},
}
