test "Invalid Country Error Exists", () ->
    ok new InvalidCountryError instanceof Error

test "Invalid Country Thrown for DigiKey", () ->
    throws () ->
        d = new Digikey("XX")
    , InvalidCountryError

