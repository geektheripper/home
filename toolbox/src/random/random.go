package random

import (
	"errors"
	"fmt"
	"strconv"
	"strings"

	mapset "github.com/deckarep/golang-set/v2"
	"github.com/google/uuid"
	"github.com/samber/lo"
	"github.com/urfave/cli/v2"
)

var ClearRunes = []rune("abdefghijmnprtyABDEFGHIJLMNPQRTY234678")

var allSpecialGenerators = mapset.NewSet("hrrs", "md5", "uuid")
var allCaseTransformers = mapset.NewSet("lower", "upper")
var allCharsetNames = mapset.NewSet("hex", "alpha", "number", "safe-ascii", "clear")
var charsetRuneMap = map[string][]rune{
	"hex":        []rune("0123456789abcdef"),
	"alpha":      []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"),
	"number":     []rune("0123456789"),
	"safe-ascii": []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~!@#%^&()_+-={}[];,."),
	"clear":      ClearRunes,
}

var Command = cli.Command{
	Name:      "random",
	Aliases:   []string{"rnd", "rand"},
	Usage:     "generate any random string",
	ArgsUsage: "[keywords](default: alpha) [length](default: 16)",
	Description: `You can use following keywords which comma separated:
Charset:
	hex: /0-9a-f/
	alpha: /a-zA-Z/
	number: /0-9/
	safe-ascii: /a-zA-Z0-9~!@#%^&()_+-={}[];,./

Transformers:
	lower: when use lower, exclude upper in charset
	upper: when use upper, exclude lower in charset

SpecialGenerators:
	hrrs: human readable (legal pronunciation) random string
	md5: can't specific length
	uuid: can't specific length
	`,
	Action: func(ctx *cli.Context) error {
		userKeywords := mapset.NewSet("alpha")
		length := 16
		lengthSet := false

		userLetterCaseTransformer := ""
		userSpecialGenerator := ""

		if ctx.NArg() >= 1 {
			userKeywords.Clear()
			userKeywordsStr := ctx.Args().First()
			for _, v := range strings.Split(userKeywordsStr, ",") {
				userKeywords.Add(v)
			}
		}

		if ctx.NArg() >= 2 {
			var err error
			length, err = strconv.Atoi(ctx.Args().Get(1))
			if err != nil {
				return err
			}
			lengthSet = true
		}

		userLetterCaseTransformers := userKeywords.Intersect(allCaseTransformers)
		if userLetterCaseTransformers.Cardinality() == 2 {
			return errors.New("case transformers can't be use together: " + strings.Join(userLetterCaseTransformers.ToSlice(), ", "))
		} else if userLetterCaseTransformers.Cardinality() == 1 {
			userLetterCaseTransformer = userLetterCaseTransformers.ToSlice()[0]
			userKeywords.Remove(userLetterCaseTransformer)
		}

		userSpecialGenerators := userKeywords.Intersect(allSpecialGenerators)

		if userSpecialGenerators.Cardinality() > 1 {
			return errors.New("special generators can't be use together: " + strings.Join(userSpecialGenerators.ToSlice(), ", "))
		}

		if userSpecialGenerators.Cardinality() == 1 {
			userSpecialGenerator = userSpecialGenerators.ToSlice()[0]
			var result string
			switch userSpecialGenerator {
			case "hrrs":
				result = GetHumanReadableRandomString(length)
			case "md5":
				if lengthSet {
					return errors.New("md5 has fixed length")
				}
				result = GetSafeRandomMD5String()
			case "uuid":
				if lengthSet {
					return errors.New("uuid has fixed length")
				}
				result = uuid.New().String()
			}
			userKeywords.Remove(userSpecialGenerator)

			if userKeywords.Cardinality() > 0 {
				return errors.New("excess argument(s): " + strings.Join(userKeywords.ToSlice(), ", "))
			}

			switch userLetterCaseTransformer {
			case "":
				fmt.Print(result)
			case "lower":
				fmt.Print(strings.ToLower(result))
			case "upper":
				fmt.Print(strings.ToUpper(result))
			}
			return nil
		}

		randomStrSourceRunes := mapset.NewSet[rune]()

		allCharsetNames.Each(func(s string) bool {
			if !userKeywords.Contains(s) {
				return false
			}
			lo.ForEach(charsetRuneMap[s], func(s rune, _ int) { randomStrSourceRunes.Add(s) })
			userKeywords.Remove(s)
			return false
		})

		if userKeywords.Cardinality() > 0 {
			return errors.New("unknown arguments: " + strings.Join(userKeywords.ToSlice(), ", "))
		}

		if userLetterCaseTransformer != "" {
			newSourceRunes := mapset.NewSet[rune]()
			randomStrSourceRunes.Each(func(s rune) bool {
				if userLetterCaseTransformer == "lower" {
					newSourceRunes.Add([]rune(strings.ToLower(string(s)))[0])
				} else {
					newSourceRunes.Add([]rune(strings.ToUpper(string(s)))[0])
				}
				return false
			})
			randomStrSourceRunes = newSourceRunes
		}

		fmt.Print(GetSafeRandomString(randomStrSourceRunes.ToSlice(), length))
		return nil
	},
}
