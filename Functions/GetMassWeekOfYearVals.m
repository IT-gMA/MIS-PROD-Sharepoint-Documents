let
    GetMassWeekOfYearVals = (
    // Contains specifications for date fields to process
    dateData as table,
    // The source table to add the respective week of year columns to
    source as table) as table =>
        let
            // Helper function to process a single date field and add week of year columns
            // Parameters:
            //   currentTable: The table being processed
            //   dateFieldSpec: Record containing date field specifications
            ProcessDateField = (currentTable as table, dateFieldSpec as record) as table =>
                let
                    // Extract field names from the specification
                    dateFieldName = dateFieldSpec[dateFieldName],
                    weekOfYearFieldNamePrefix = dateFieldSpec[weekOfYearFieldNamePrefix],
                    // Check if the specified date column exists in the table
                    HasColumn = List.Contains(Table.ColumnNames(currentTable), dateFieldName),
                    // Helper function to safely extract and convert date values
                    GetDateValue = (row as record) as any =>
                        let
                            rawValue = Record.Field(row, dateFieldName),
                            dateValue = if rawValue = null then null else Date.From(rawValue)
                        in
                            dateValue,
                    // Process the table if the column exists, otherwise return unchanged
                    ResultTable =
                        if HasColumn then
                            let
                                // Add string representation of week of year
                                WithStringColumn = Table.AddColumn(
                                    currentTable,
                                    weekOfYearFieldNamePrefix & ".str",
                                    each GetWeekOfYear(GetDateValue(_), true),
                                    type nullable text
                                ),
                                // Add date representation of week of year
                                WithDateColumn = Table.AddColumn(
                                    WithStringColumn,
                                    weekOfYearFieldNamePrefix & ".date",
                                    each GetWeekOfYear(GetDateValue(_), false),
                                    type nullable date
                                )
                            in
                                WithDateColumn
                        else
                            currentTable
                in
                    ResultTable,
            // Process all date fields specified in dateData using List.Accumulate
            // This iteratively applies ProcessDateField for each specification
            Result = List.Accumulate(
                Table.ToRecords(dateData), source, (state, current) => ProcessDateField(state, current)
            )
        in
            Result
in
    GetMassWeekOfYearVals
