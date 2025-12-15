let
    GetExpiryCategory = (isComplete as logical, hasExpiryDate as logical, daysTillExpiry as nullable number) as text =>
        // Any training that doesn't have an Expiry Date is considered to never expire i.e Compliant
        if isComplete and daysTillExpiry = null then
            "Compliant"
            // Training with both empty Complete and Expiry dates
        else if not isComplete and not hasExpiryDate then
            if daysTillExpiry = null then
                "Unknown"
            else if daysTillExpiry <= 0 then
                "Non Compliant"
            else
                "Not Yet Required"
        else if daysTillExpiry = null or daysTillExpiry > 180 then
            "Compliant"
        else if daysTillExpiry <= 0 then
            "Expired"
        else if daysTillExpiry <= 30 then
            "Expires in 30 Days"
        else if daysTillExpiry <= 60 then
            "Expires in 60 Days"
        else if daysTillExpiry <= 90 then
            "Expires in 90 Days"
        else if daysTillExpiry <= 120 then
            "Expires in 120 Days"
        else if daysTillExpiry <= 150 then
            "Expires in 150 Days"
        else if daysTillExpiry <= 180 then
            "Expires in 180 Days"
        else
            "Unknown"
in
    GetExpiryCategory
