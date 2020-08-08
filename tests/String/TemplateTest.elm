module String.TemplateTest exposing (all)

import Expect
import Fuzz exposing (Fuzzer)
import String.Template exposing (inject)
import Test exposing (Test, concat, describe, fuzz, test)


all : Test
all =
    concat
        [ validPlaceholdersUnitTests
        , validPlaceholdersFuzzTest
        ]


validPlaceholdersUnitTests : Test
validPlaceholdersUnitTests =
    [ { template = "${}"
      , toInject = [ ( "", "x" ) ]
      , expect = "x"
      }
    , { template = "${foo}"
      , toInject = [ ( "foo", "bar" ) ]
      , expect = "bar"
      }
    , { template = "${ foo }"
      , toInject = [ ( " foo ", "bar" ) ]
      , expect = "bar"
      }
    , { template = "${${}"
      , toInject = [ ( "${", "foo" ) ]
      , expect = "foo"
      }
    , { template = "$${foo}}"
      , toInject = [ ( "foo", "bar" ) ]
      , expect = "$bar}"
      }
    , { template = "${identity}"
      , toInject = [ ( "identity", "${identity}" ) ]
      , expect = "${identity}"
      }
    ]
        |> List.map
            (\{ template, toInject, expect } ->
                Test.test template
                    (\_ ->
                        inject toInject template
                            |> Expect.equal expect
                    )
            )
        |> Test.describe "Valid placeholders unit tests"


validPlaceholdersFuzzTest : Test
validPlaceholdersFuzzTest =
    Test.fuzz placeholderFuzzer "Valid placeholders fuzz test" <|
        \{ placeholder, name } ->
            inject [ ( name, "foo" ) ] placeholder
                |> Expect.equal "foo"



-- Fuzzers


placeholderFuzzer : Fuzzer { placeholder : String, name : String }
placeholderFuzzer =
    Fuzz.map
        (\name -> { placeholder = "${" ++ name ++ "}", name = name })
        placeholderNameFuzzer


placeholderNameFuzzer : Fuzzer String
placeholderNameFuzzer =
    Fuzz.string
        |> Fuzz.map (String.replace "}" "")
