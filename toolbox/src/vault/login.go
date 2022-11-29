package vault

import (
	"os"

	"github.com/geektheripper/planetarian/toolbox/v2/src/utils"
	"github.com/hashicorp/vault/api/auth/userpass"
	"github.com/manifoldco/promptui"
	"github.com/samber/lo"
	"github.com/urfave/cli/v2"
)

// login
var vaultUsername string
var vaultTokenFile string

var commandLogin = cli.Command{
	Name: "login",
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:        "username",
			EnvVars:     []string{"VAULT_USER"},
			Aliases:     []string{"u"},
			Required:    true,
			Destination: &vaultUsername,
		},
		&cli.StringFlag{
			Name:        "token-file",
			EnvVars:     []string{"VAULT_TOKEN_FILE"},
			Aliases:     []string{"f"},
			Destination: &vaultTokenFile,
		},
	},
	Action: func(cCtx *cli.Context) error {
		client := GetEmptyVaultClient()
		prompt := promptui.Prompt{
			Label:       "Password",
			Stdout:      os.Stderr,
			Mask:        '*',
			HideEntered: true,
		}
		password := lo.Must(prompt.Run())

		userpassAuth := lo.Must(userpass.NewUserpassAuth(
			vaultUsername,
			&userpass.Password{FromString: password},
			userpass.WithMountPath("userpass"),
		))

		secret, err := client.Auth().Login(cCtx.Context, userpassAuth)
		if err != nil {
			return err
		}

		token := []byte(lo.Must(secret.TokenID()))

		if vaultTokenFile != "" {
			os.WriteFile(vaultTokenFile, token, 0600)
		}

		return nil
	},
}

var commandSu = cli.Command{
	Name: "su",
	Action: func(cCtx *cli.Context) error {
		prompt := promptui.Prompt{
			Label:       "Token",
			Stdout:      os.Stderr,
			Mask:        '*',
			HideEntered: true,
		}

		token := lo.Must(prompt.Run())

		shell := utils.ShellExec{}
		return shell.Assign("VAULT_ROOT_TOKEN", token).PrintScript()
	},
}
