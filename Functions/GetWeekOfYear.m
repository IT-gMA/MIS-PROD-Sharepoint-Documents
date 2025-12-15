let
    GetWeekOfYear = (dateValue as nullable date, optional getString as logical) as any =>
        let
            // Set default value for getString parameter if not provided
            getStringValue = if getString = null then true else getString,
            // Handle null date input
            Result =
                if dateValue = null then
                    null
                else
                    let
                        // Calculate the first day of the week containing the input date
                        // Using ISO week definition (week starts on Monday)
                        dayOfWeek = Date.DayOfWeek(dateValue, Day.Monday),
                        firstDayOfWeek = Date.AddDays(dateValue, -dayOfWeek),
                        // Get the week number and year
                        weekNumber = Date.WeekOfYear(dateValue, Day.Monday),
                        year = Date.Year(dateValue),
                        // Format the result based on getString parameter
                        formattedResult =
                            if getStringValue then
                                "Week " & Text.From(weekNumber) & ", " & Text.From(year)
                            else
                                firstDayOfWeek
                    in
                        formattedResult
        in
            Result
in
    GetWeekOfYear
