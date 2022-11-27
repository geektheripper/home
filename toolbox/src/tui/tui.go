package tui

import (
	"errors"
	"os"
	"regexp"

	"github.com/geektheripper/planetarian/toolbox/v2/src/utils"
	"github.com/go-playground/validator/v10"
	"github.com/manifoldco/promptui"
	"github.com/urfave/cli/v2"
)

var flagDefault string
var flagLabel string
var flagType string
var flagSecret bool

var Command = cli.Command{
	Name:  "tui",
	Usage: "user interface utils",
	Subcommands: []*cli.Command{
		{
			Name: "input",
			Flags: []cli.Flag{
				&cli.StringFlag{
					Name:        "default",
					Aliases:     []string{"d"},
					Usage:       "provide default value",
					Destination: &flagDefault,
				},
				&cli.StringFlag{
					Name:        "label",
					Aliases:     []string{"l"},
					DefaultText: "Input",
					Usage:       "text on the left of input area",
					Destination: &flagLabel,
				},
				&cli.StringFlag{
					Name:        "type",
					Aliases:     []string{"t"},
					Usage:       "used to validate user input",
					Destination: &flagType,
				},
				&cli.BoolFlag{
					Name:        "secret",
					Aliases:     []string{"s"},
					Usage:       "hide the text after enter pressed",
					Destination: &flagSecret,
				},
			},
			Usage: "prompt and validate user input",
			Description: `use https://github.com/go-playground/validator as type
validator, so all these types will be work:
cidr, cidrv4, cidrv6, datauri, fqdn, hostname, hostname_port, hostname_rfc1123, ip, ip4_addr, ip6_addr, ip_addr, ipv4, ipv6, mac, tcp4_addr, tcp6_addr, tcp_addr, udp4_addr, udp6_addr, udp_addr, unix_addr, uri, url, url_encoded, urn_rfc2141, alpha, alphanum, alphanumunicode, alphaunicode, ascii, boolean, contains, containsany, containsrune, endsnotwith, endswith, excludes, excludesall, excludesrune, lowercase, multibyte, number, numeric, printascii, startsnotwith, startswith, uppercase, base64, base64url, bic, bcp47_language_tag, btc_addr, btc_addr_bech32, credit_card, datetime, e164, email, eth_addr, hexadecimal, hexcolor, hsl, hsla, html, html_encoded, isbn, isbn10, isbn13, iso3166_1_alpha2, iso3166_1_alpha3, iso3166_1_alpha_numeric, iso3166_2, iso4217, json, jwt, latitude, longitude, postcode_iso3166_alpha2, postcode_iso3166_alpha2_field, rgb, rgba, ssn, timezone, uuid, uuid3, uuid3_rfc4122, uuid4, uuid4_rfc4122, uuid5, uuid5_rfc4122, uuid_rfc4122, md4, md5, sha256, sha384, sha512, ripemd128, ripemd128, tiger128, tiger160, tiger192, semver, ulid, dir, file, isdefault, len, max, min, oneof, required, required_if, required_unless, required_with, required_with_all, required_without, required_without_all, excluded_if, excluded_unless, excluded_with, excluded_with_all, excluded_without, excluded_without_all, unique`,
			Action: func(cCtx *cli.Context) error {
				var vldt *validator.Validate
				var re *regexp.Regexp

				if flagType != "" {
					vldt = validator.New()
					re, _ = regexp.Compile("^Key: '' Error:Field validation for '' failed on the '(.+)?' tag$")
				}

				validate := func(s string) error {
					err := vldt.Var(s, flagType)
					if err == nil {
						return nil
					}
					tagName := re.FindSubmatch([]byte(err.Error()))
					return errors.New("input mismatch '" + string(tagName[1]) + "' tag")
				}

				// if !ok && flagType != "" {
				// 	return errors.New("Invalid type: " + flagType)
				// }

				prompt := promptui.Prompt{
					Validate: validate,
					Label:    flagLabel,
					Stdout:   os.Stderr,
				}

				if flagSecret {
					prompt.Mask = '*'
					prompt.HideEntered = true
				}

				result, err := prompt.Run()

				if err != nil {
					utils.ErrLog.Printf("Prompt failed %v\n", err)
					return nil
				}

				os.Stdout.Write([]byte(result))
				return nil
			},
		},
	},
}
