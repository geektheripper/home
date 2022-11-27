package text_block

import (
	"errors"
	"io/fs"
	"strings"

	"github.com/geektheripper/planetarian/toolbox/v2/src/utils"
	"github.com/samber/lo"
	"github.com/urfave/cli/v2"
)

// static
const boundaryPrefix string = "⭒☆━━━━━━━━ "
const boundarySuffix string = " ━━━━━━━━☆⭒"

// config by flags
var blockEscape string
var blockKey string
var targetFile string
var targetFileModeNumber uint

// shared variable
var blockBoundary string

var Command = cli.Command{
	Name:     "text-block",
	Aliases:  []string{"tblk"},
	Category: "editor",
	Usage:    "manage text block in file",
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:        "file",
			Aliases:     []string{"f"},
			Usage:       "target file",
			Required:    true,
			Destination: &targetFile,
		}, &cli.StringFlag{
			Name:        "escape",
			Aliases:     []string{"e"},
			Value:       "# ",
			Usage:       "escape of block boundary",
			Destination: &blockEscape,
		}, &cli.StringFlag{
			Name:        "key",
			Aliases:     []string{"k"},
			Usage:       "block key",
			Required:    true,
			Destination: &blockKey,
		}, &cli.UintFlag{
			Name:        "mode",
			Aliases:     []string{"m"},
			Usage:       "file mode",
			Destination: &targetFileModeNumber,
		},
	},
	Before: func(cCtx *cli.Context) error {
		// # ⭒☆━━━━━━━━ example_key ━━━━━━━━☆⭒
		blockBoundary = blockEscape + boundaryPrefix + blockKey + boundarySuffix
		return nil
	},
	Subcommands: []*cli.Command{
		{
			Name:      "write",
			ArgsUsage: "<content>",
			Usage:     "write text block",
			Action: func(cCtx *cli.Context) error {
				mode := fs.FileMode(targetFileModeNumber)

				blockContent := strings.Join(cCtx.Args().Slice(), " ")
				if blockContent == "" || blockContent == "-" {
					blockContent = lo.Must(utils.StdinText())
				}
				block := blockBoundary + "\n" + blockContent + "\n" + blockBoundary

				fileContent, err := utils.ReadFile(targetFile)
				if err != nil {
					return err
				}

				contentSlice := strings.Split(fileContent, blockBoundary)
				if len(contentSlice) == 1 {
					fileContent = utils.TrimJoinLines(contentSlice[0], block)
				} else if len(contentSlice) == 3 {
					fileContent = utils.TrimJoinLines(contentSlice[0], block, contentSlice[2])
				} else {
					return errors.New("error boundaries number in file, should be 2 or 0")
				}

				return utils.WriteFile(targetFile, fileContent, mode)
			},
		},
		{
			Name:  "rm",
			Usage: "remove text block",
			Action: func(cCtx *cli.Context) error {
				mode := fs.FileMode(targetFileModeNumber)

				fileContent, err := utils.ReadFile(targetFile)
				if err != nil {
					return err
				}

				contentSlice := strings.Split(fileContent, blockBoundary)
				if len(contentSlice) == 1 {
					return nil
				} else if len(contentSlice) == 3 {
					return utils.WriteFile(targetFile, utils.TrimJoinLines(contentSlice[0], contentSlice[2]), mode)
				} else {
					return errors.New("error boundaries number in file, should be 2 or 0")
				}
			},
		},
	},
}
