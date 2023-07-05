package veracrypt

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"os/user"
	"path"
	"strconv"
	"strings"
	"syscall"

	"github.com/geektheripper/planetarian/toolbox/v2/src/random"
	"github.com/geektheripper/planetarian/toolbox/v2/src/utils"
	"github.com/moby/sys/mountinfo"
	"github.com/samber/lo"
	"github.com/urfave/cli/v2"
)

func getUser() (*user.User, *user.User) {
	currentUser := lo.Must(user.Current())
	originUid := os.Getenv("SUDO_UID")
	if originUid == "" {
		originUid = currentUser.Uid
	}
	originUser := lo.Must(user.LookupId(originUid))
	return currentUser, originUser
}

func pathNotExists(path string) bool {
	_, err := os.Stat(path)
	return os.IsNotExist(err)
}

var currentUser, originUser = getUser()

var hiddenCommandEnsure = cli.Command{
	Name:   "ensure-562f8c2c-ba65-4171-bb09-60e0d1d06498",
	Hidden: true,
	Action: func(c *cli.Context) error {
		veracryptExecutable := os.Getenv("VERACRYPT_EXECUTABLE")
		mountPoint := os.Getenv("MOUNT_POINT")
		volumeBaseDir := os.Getenv("VOLUME_BASE_DIR")
		volumeFile := os.Getenv("VOLUME_FILE")
		shouldCreateVolume := os.Getenv("SHOULD_CREATE_VOLUME") == "true"
		password := os.Getenv("PASSWORD")
		size := os.Getenv("SIZE")

		log.Printf("✔️ make sure mount point: %s", mountPoint)
		if _, err := os.Stat(mountPoint); err == nil {
			log.Printf("already exists")
		} else if os.IsNotExist(err) {
			if err := os.MkdirAll(mountPoint, 0700); err == nil {
				log.Printf("mount point created")
			} else {
				return err
			}
		} else {
			log.Printf("failed: %s", err)
			return err
		}

		log.Printf("✔️ make sure volume base dir: %s", volumeBaseDir)
		if _, err := os.Stat(volumeBaseDir); err == nil {
			log.Printf("already exists")
		} else if os.IsNotExist(err) {
			if err := os.MkdirAll(volumeBaseDir, 0700); err == nil {
				log.Printf("volume base dir created")
			} else {
				return err
			}
		} else {
			log.Printf("failed: %s", err)
			return err
		}

		if shouldCreateVolume {
			log.Printf("✔️ create volume file: %s", volumeFile)
			log.Printf("generating, please wait...")
			cmd := exec.Command(veracryptExecutable, "--create", volumeFile, "--size="+size, "--volume-type=normal", "--encryption=aes", "--hash=sha-256", "--filesystem=ext4", "--pim=0", "--keyfiles=", "--random-source", "/dev/random", "--password="+password)
			cmd.Stderr = os.Stderr
			cmd.Stdout = os.Stdout
			cmd.Env = os.Environ()

			if err := cmd.Run(); err != nil {
				return err
			}
		}

		log.Printf("✔️ mount volume file: %s", volumeFile)

		mounted, sure, err := mountinfo.MountedFast(mountPoint)
		if err != nil {
			log.Printf("failed to check mount status: %s", err)
			return err
		}
		if !sure {
			log.Printf("failed to check mount status: not sure")
			return fmt.Errorf("failed to check mount status: not sure")
		}
		if mounted {
			log.Printf("already mounted")
			return nil
		}

		cmd := exec.Command(veracryptExecutable, "--mount", volumeFile, mountPoint, "--pim=0", "--keyfiles=", "--volume-type=normal", "--protect-hidden=no", "--password="+password)
		cmd.Stderr = os.Stderr
		cmd.Stdout = os.Stdout

		if err := cmd.Run(); err != nil {
			return err
		}

		return nil
	},
}

var commandEnsure = cli.Command{
	Name:  "ensure",
	Usage: "ensure veracrypt volume is created and mounted",
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
		&cli.StringFlag{
			Name:     "size",
			Usage:    "veracrypt volume size",
			Required: true,
		},
		&cli.StringFlag{
			Name:     "mount-point",
			Usage:    "veracrypt volume mount point",
			Required: true,
		},
		&cli.StringFlag{
			Name:    "password",
			Usage:   "veracrypt volume password",
			EnvVars: []string{"VERACRYPT_PASSWORD"},
		},
	},
	Action: func(c *cli.Context) error {
		originUid := lo.Must(strconv.Atoi(originUser.Uid))
		originGid := lo.Must(strconv.Atoi(originUser.Gid))
		veracryptExecutable, err := exec.LookPath("veracrypt")
		if err != nil {
			log.Printf("failed to find veracrypt executable")
			return err
		}

		baseDir := c.String("base-dir")
		namespace := c.String("namespace")
		name := c.String("name")
		mountPoint := c.String("mount-point")
		password := c.String("password")

		volumeBaseDir := path.Join(baseDir, namespace)
		volumeFile := path.Join(volumeBaseDir, name+".hc")

		shouldCreateVolume := pathNotExists(volumeFile)

		// ensure password
		if password == "" {
			if shouldCreateVolume {
				defaultPassword := random.GetSafeRandomString(random.ClearRunes, 30)
				readableDefaultPassword := strings.Join(lo.ChunkString(defaultPassword, 5), " ")
				log.Printf("left blank to generated one")
				password = utils.ReadInput("Input Password", "", "", true)

				if password == "" {
					password = defaultPassword
					log.Printf("password: %s", readableDefaultPassword)
				} else {
					passwordConfirm := utils.ReadInput("Input Password Again", "", "", true)
					if password != passwordConfirm {
						utils.ErrLog.Fatal("password not match")
						return nil
					}
				}
			} else {
				password = utils.ReadInput("Input Password", "", "", true)
			}
		}

		cmd := exec.Command(os.Args[0], os.Args[1], hiddenCommandEnsure.Name)
		cmd.Stderr = os.Stderr
		cmd.Stdout = os.Stdout
		// run as origin user
		cmd.Env = []string{
			fmt.Sprintf("LANGUAGE=%s", os.Getenv("LANGUAGE")),
			fmt.Sprintf("LANG=%s", os.Getenv("LANG")),
			fmt.Sprintf("LC_ALL=%s", os.Getenv("LC_ALL")),
			fmt.Sprintf("TERM=%s", os.Getenv("TERM")),
			fmt.Sprintf("COLORTERM=%s", os.Getenv("COLORTERM")),
			fmt.Sprintf("LS_COLORS=%s", os.Getenv("LS_COLORS")),
			// user info
			fmt.Sprintf("LOGNAME=%s", originUser.Username),
			fmt.Sprintf("USER=%s", originUser.Username),
			fmt.Sprintf("HOME=%s", originUser.HomeDir),
			// provide env
			fmt.Sprintf("VERACRYPT_EXECUTABLE=%s", veracryptExecutable),
			fmt.Sprintf("MOUNT_POINT=%s", mountPoint),
			fmt.Sprintf("VOLUME_BASE_DIR=%s", volumeBaseDir),
			fmt.Sprintf("VOLUME_FILE=%s", volumeFile),
			fmt.Sprintf("SHOULD_CREATE_VOLUME=%t", shouldCreateVolume),
			fmt.Sprintf("PASSWORD=%s", password),
			fmt.Sprintf("SIZE=%s", c.String("size")),
		}
		cmd.SysProcAttr = &syscall.SysProcAttr{
			Credential: &syscall.Credential{Uid: uint32(originUid), Gid: uint32(originGid)},
		}

		if err := cmd.Run(); err != nil {
			return err
		}

		if shouldCreateVolume {
			// change mount point owner if not current user
			info, err := os.Stat(mountPoint)
			if err != nil {
				return err
			}

			if info.Sys().(*syscall.Stat_t).Uid != uint32(originUid) {
				if err := os.Chown(mountPoint, originUid, originGid); err != nil {
					return err
				}
			}
		}

		return nil
	},
}
