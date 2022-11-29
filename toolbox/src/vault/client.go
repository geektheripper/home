package vault

import (
	"context"
	"errors"
	"os"
	"path"
	"strings"

	"github.com/geektheripper/planetarian/toolbox/v2/src/utils"
	vault "github.com/hashicorp/vault/api"
	"github.com/samber/lo"
)

func GetEmptyVaultClient() *vault.Client {
	config := vault.DefaultConfig()
	config.Address = utils.MustGetEnv("VAULT_ADDR")
	client := lo.Must(vault.NewClient(config))
	return client
}

func GetVaultClient() *vault.Client {
	client := GetEmptyVaultClient()

	token := os.Getenv("VAULT_ROOT_TOKEN")

	if token == "" {
		file := utils.DefaultsEnv("VAULT_TOKEN_FILE", path.Join(lo.Must(os.UserHomeDir()), ".vault-token"))
		token = strings.Trim(utils.MustReadFile(file), "\n")
	}

	client.SetToken(token)
	return client
}

func GetSecret(ctx context.Context, engine string, path string) (*vault.KVSecret, error) {
	result := strings.SplitN(path, "/", 2)
	secretMountPath := result[0]
	secretPath := result[1]

	client := GetVaultClient()

	switch engine {
	case "":
		v2, err := client.KVv2(secretMountPath).Get(ctx, secretPath)
		if err == nil && v2 != nil {
			return v2, err
		}
		return client.KVv1(secretMountPath).Get(ctx, secretPath)
	case "kv2":
		return client.KVv2(secretMountPath).Get(ctx, secretPath)
	case "kv1":
		return client.KVv1(secretMountPath).Get(ctx, secretPath)
	default:
		return nil, errors.New("unknown engine")
	}
}
