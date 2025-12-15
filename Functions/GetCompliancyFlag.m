let
    GetCompliancyFlag = (expiryCategory as text) as logical =>
        not List.Contains({"Non Compliant", "Expired", "Unknown"}, expiryCategory)
in
    GetCompliancyFlag
