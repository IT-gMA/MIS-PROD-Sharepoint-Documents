let
    GetDaysTillExpiry = (
        isComplete as logical,
        hasExpiryDate as logical,
        // Every Bookable Resource Characteristic with isMissingTraining = true will always has isComplete = false and hasExpiryDate = false (for now it's not needed) isMissingTraining as logical,
        expiryDate as nullable date,
        lastCompleted as nullable date,
        expiryUnit as nullable number,
        expiryPeriod as nullable number,
        firstStartDate as nullable date,
        weeksOfStart as nullable number
    ) as nullable number =>
        let
            todaysDate = Date.From(DateTimeZone.SwitchZone(DateTimeZone.FixedUtcNow(), 8)),
            // Handle case where training is not complete
            daysTillExpiry =
                if not isComplete then
                    if not hasExpiryDate then
                        // Training Compliancy has both empty Complete and Expiry Dates
                        if weeksOfStart <> null and firstStartDate <> null then
                            Duration.Days(Date.AddWeeks(firstStartDate, weeksOfStart) - todaysDate)
                        else
                            null
                    else
                        Duration.Days(expiryDate - todaysDate)
                    // Handle case where training is complete and has valid expiry unit/period
                else if List.Contains({864630000, 864630001, 864630002, 864630003}, expiryUnit) and expiryPeriod <> null then
                    Duration.Days(
                        (
                            if expiryUnit = 864630000 then
                                // Days
                                Date.AddDays(lastCompleted, expiryPeriod)
                            else if expiryUnit = 864630001 then
                                // Weeks
                                Date.AddWeeks(lastCompleted, expiryPeriod)
                            else if expiryUnit = 864630002 then
                                // Months
                                Date.AddMonths(lastCompleted, expiryPeriod)
                            else
                                // Years
                                Date.AddYears(lastCompleted, expiryPeriod)
                        ) - todaysDate
                    )
                    // Handle case where training has explicit expiry date
                else if hasExpiryDate then
                    Duration.Days(expiryDate - todaysDate)
                else
                    null
        in
            daysTillExpiry
in
    GetDaysTillExpiry
