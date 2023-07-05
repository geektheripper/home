package veracrypt

import (
	"log"
	"os/exec"
	"path"

	"github.com/urfave/cli/v2"
)

var umountCommand = cli.Command{
	Name:  "umount",
	Usage: "umount veracrypt volume",
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:    "base-dir",
			EnvVars: []string{"VERACRYPT_BASE_DIR"},
			Usage:   "veracrypt volume base dir",
			Value:   path.Join(originUser.HomeDir, ".veracrypt"),
		},
		&cli.StringFlag{
			Name:     "namespace",
			Usage:    "namespace for veracrypt volume",
			Required: true,
		},
		&cli.StringFlag{
			Name:     "name",
			Usage:    "veracrypt volume name",
			Required: true,
		},
	},
	Action: func(c *cli.Context) error {
		baseDir := c.String("base-dir")
		namespace := c.String("namespace")
		name := c.String("name")

		volumeFile := path.Join(baseDir, namespace, name+".hc")

		if err := exec.Command("sync").Run(); err != nil {
			return err
		}

		if err := exec.Command("veracrypt", "--text", "--dismount", volumeFile).Run(); err != nil {
			log.Panicf("failed to umount volume %s: %v", volumeFile, err)
			return err
		}

		return nil
	},
}
