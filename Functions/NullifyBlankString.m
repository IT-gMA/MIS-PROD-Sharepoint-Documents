let
    // Normalises blank strings to null for consistent data handling
    // Handles three cases: null input, whitespace-only strings, and valid strings
    NullifyBlankString = (str as nullable text) as nullable text =>
        if str = null then
            null
            // Return null if input is already null
        else if Text.Length(Text.Replace(Text.Trim(str), " ", "")) < 1 then
            null
            // Return null if string is empty or contains only whitespace
        else
            str
    // Return original string if it contains meaningful content
in
    NullifyBlankString
