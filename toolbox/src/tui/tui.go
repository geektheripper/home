package tui

import (
	"os"
	"strings"

	"github.com/geektheripper/planetarian/toolbox/v2/src/utils"
	"github.com/samber/lo"
	"github.com/urfave/cli/v2"
)

var Command = cli.Command{
	Name:  "tui",
	Usage: "user interface utils",
	Subcommands: []*cli.Command{
		{
			Name: "input",
			Flags: []cli.Flag{
				&cli.StringFlag{
					Name:    "default",
					Aliases: []string{"d"},
					Usage:   "provide default value",
				},
				&cli.StringFlag{
					Name:    "label",
					Aliases: []string{"l"},
					Value:   "Input",
					Usage:   "text on the left of input area",
				},
				&cli.StringFlag{
					Name:    "type",
					Aliases: []string{"t"},
					Usage:   "used to validate user input",
				},
				&cli.BoolFlag{
					Name:    "secret",
					Aliases: []string{"s"},
					Usage:   "hide the text after enter pressed",
				},
			},
			Usage: "prompt and validate user input",
			Description: `use https://github.com/go-playground/validator as type
validator, so all these types will be work:
cidr, cidrv4, cidrv6, datauri, fqdn, hostname, hostname_port, hostname_rfc1123, ip, ip4_addr, ip6_addr, ip_addr, ipv4, ipv6, mac, tcp4_addr, tcp6_addr, tcp_addr, udp4_addr, udp6_addr, udp_addr, unix_addr, uri, url, url_encoded, urn_rfc2141, alpha, alphanum, alphanumunicode, alphaunicode, ascii, boolean, contains, containsany, containsrune, endsnotwith, endswith, excludes, excludesall, excludesrune, lowercase, multibyte, number, numeric, printascii, startsnotwith, startswith, uppercase, base64, base64url, bic, bcp47_language_tag, btc_addr, btc_addr_bech32, credit_card, datetime, e164, email, eth_addr, hexadecimal, hexcolor, hsl, hsla, html, html_encoded, isbn, isbn10, isbn13, iso3166_1_alpha2, iso3166_1_alpha3, iso3166_1_alpha_numeric, iso3166_2, iso4217, json, jwt, latitude, longitude, postcode_iso3166_alpha2, postcode_iso3166_alpha2_field, rgb, rgba, ssn, timezone, uuid, uuid3, uuid3_rfc4122, uuid4, uuid4_rfc4122, uuid5, uuid5_rfc4122, uuid_rfc4122, md4, md5, sha256, sha384, sha512, ripemd128, ripemd128, tiger128, tiger160, tiger192, semver, ulid, dir, file, isdefault, len, max, min, oneof, required, required_if, required_unless, required_with, required_with_all, required_without, required_without_all, excluded_if, excluded_unless, excluded_with, excluded_with_all, excluded_without, excluded_without_all, unique`,
			Action: func(cCtx *cli.Context) error {
				os.Stdout.Write([]byte(utils.ReadInput(
					cCtx.String("label"),
					cCtx.String("default"),
					cCtx.String("type"),
					cCtx.Bool("secret"),
				)))
				return nil
			},
		},
		{
			Name: "select",
			Flags: []cli.Flag{
				&cli.StringFlag{
					Name:    "prompt",
					Aliases: []string{"l"},
					Value:   "Select",
					Usage:   "text on the left of select area",
				},
				&cli.StringFlag{
					Name:    "list",
					Aliases: []string{"i"},
					Usage:   "list to select, split by delimiter",
				},
				&cli.StringFlag{
					Name:    "delimiter",
					Aliases: []string{"d"},
					Value:   ",",
					Usage:   "delimiter of list",
				},
			},
			Usage: "prompt and select one item",
			Action: func(cCtx *cli.Context) error {
				list := strings.Split(cCtx.String("list"), cCtx.String("delimiter"))
				list = lo.Filter(list, func(input string, _ int) bool { return input != "" })
				os.Stdout.Write([]byte(utils.ReadSelect(cCtx.String("prompt"), list)))
				return nil
			},
		},
	},
}
