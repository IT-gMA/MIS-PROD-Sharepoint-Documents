let
    BulkInvokeNullifyBlankString = (sourceTable as table, optional excludedColumns as nullable list) as table =>
        let
            _excludedColumns =
                if excludedColumns = null then
                    {}
                else if List.Count(excludedColumns) < 1 then
                    {}
                else
                    excludedColumns,
            // Bulk transform all text-type columns to handle blank values as nulls for consistency
            // This approach automatically handles all text columns without manual column listing
            // First, identify all text-type columns dynamically by inspecting the table schema
            TextColumnNames = Table.Column(
                Table.SelectRows(
                    Table.Schema(sourceTable),
                    each
                        [Kind] = "text"
                        and (
                            if List.Count(_excludedColumns) < 1 then
                                true
                            else
                                not List.Contains(_excludedColumns, [Name])
                        )
                ),
                "Name"
            ),
            // Then, apply the transformation to the identified text columns
            InvokeNullifyBlankStringFunction = Table.TransformColumns(
                sourceTable, List.Transform(
                    TextColumnNames, each {_, each NullifyBlankString(_), type nullable text}
                )
            )
        in
            InvokeNullifyBlankStringFunction
in
    BulkInvokeNullifyBlankString
