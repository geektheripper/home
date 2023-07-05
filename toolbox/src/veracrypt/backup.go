package veracrypt

import (
	"crypto/md5"
	"encoding/hex"
	"errors"
	"io"
	"log"
	"os"
	"os/exec"
	"path"
	"time"

	"github.com/urfave/cli/v2"
)

func hashFile(path string) (string, error) {
	h := md5.New()
	f, err := os.Open(path)
	if err != nil {
		return "", err
	}
	defer f.Close()
	if _, err := io.Copy(h, f); err != nil {
		return "", err
	}
	return hex.EncodeToString(h.Sum(nil)), nil
}

var backupCommand = cli.Command{
	Name:  "backup",
	Usage: "backup veracrypt volume",
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:    "base-dir",
			EnvVars: []string{"VERACRYPT_BASE_DIR"},
			Usage:   "veracrypt volume base dir",
			Value:   path.Join(originUser.HomeDir, ".veracrypt"),
		},
		&cli.StringFlag{
			Name:        "target-dir",
			Usage:       "backup target dir",
			DefaultText: ".backup under base dir",
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
		targetDir := c.String("target-dir")
		namespace := c.String("namespace")
		name := c.String("name")

		if targetDir == "" {
			targetDir = path.Join(baseDir, ".backup")
		}

		volumeFile := path.Join(baseDir, namespace, name+".hc")
		backupBaseDir := path.Join(targetDir, namespace)
		backupFile := path.Join(backupBaseDir, name+".hc")

		if err := exec.Command("sync").Run(); err != nil {
			return err
		}

		volumeHash, err := hashFile(volumeFile)
		if err != nil {
			return err
		}

		// if backup file exists, rename it
		if _, err := os.Stat(backupFile); err != nil {
			if !os.IsNotExist(err) {
				log.Printf("failed to stat backup file: %s", backupFile)
				return err
			}
		} else {
			// get hash of backup file
			backupHash, err := hashFile(backupFile)
			if err != nil {
				return err
			}

			if backupHash == volumeHash {
				log.Printf("backup file is same as volume file, skipping backup")
				return nil
			}

			date := time.Now().Format("20060102-150405")
			if err := os.Rename(backupFile, path.Join(backupBaseDir, name+"-"+date+".hc")); err != nil {
				return err
			}
		}

		// copy volume file to backup file
		if err := os.MkdirAll(backupBaseDir, 0755); err != nil {
			return err
		}

		// copy file using golang
		src, err := os.Open(volumeFile)
		if err != nil {
			return err
		}
		defer src.Close()

		dst, err := os.Create(backupFile)
		if err != nil {
			return err
		}
		defer dst.Close()

		if _, err := io.Copy(dst, src); err != nil {
			return err
		}

		if err := dst.Sync(); err != nil {
			return err
		}

		backupHash, err := hashFile(backupFile)
		if err != nil {
			return err
		}

		if backupHash != volumeHash {
			log.Printf("backup failed, maybe volume file is changed during backup, or disk is full")
			return errors.New("hash not match")
		}

		log.Printf("volume backup success")

		return nil
	},
}
