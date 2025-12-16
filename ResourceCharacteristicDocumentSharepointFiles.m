let
    // Construct the full parent directory path by combining the base URL with the directory parameter
    ParentDirectoryFullPath = MIS_Digital_Evolution_url & "/" & BookableResourceCharacteristicDirectory & "/",
    // Connect to SharePoint and retrieve all files from the specified site
    Source = SharePoint.Files(MIS_Digital_Evolution_url, [ApiVersion = 15]),
    // Filter files to only include those within the target parent directory structure
    NavigateToParentDirectory = Table.SelectRows(
        Source, each Text.StartsWith([Folder Path], ParentDirectoryFullPath)
    ),
    // Extract the directory name by removing the parent path prefix and any trailing slashes
    #"Get directory's name" = Table.AddColumn(
        NavigateToParentDirectory,
        "directoryName",
        each Text.Replace(Text.Replace([Folder Path], ParentDirectoryFullPath, ""), "/", ""),
        type text
    ),
    // Create a join key by extracting the UID from the directory name (assumes format: something_UID)
    // The UID is expected to be the last part after splitting by underscore
    #"Add join key with BookableResourceCharacteristics" = Table.AddColumn(
        #"Get directory's name",
        "_bkch.uid",
        // Bookable Resource Characteristics's UID extracted from Dataflow is always uppercase
        // also need to remove the hyphen (-) from the joined UID
        each try Text.Upper(Text.Replace(List.Last(Text.Split([directoryName], "_")), "-", "")) otherwise null,
        type nullable text
    ),
    // Add directory path as a custom column for easier reference
    AddCustomColumn0 = Table.AddColumn(
        #"Add join key with BookableResourceCharacteristics", "directoryPath", each [Folder Path], type text
    ),
    // Add file name as a custom column
    AddCustomColumn1 = Table.AddColumn(AddCustomColumn0, "fileName", each [Name], type text),
    // Construct the full file path by combining directory path and file name
    AddCustomColum2 = Table.AddColumn(AddCustomColumn1, "filePath", each [directoryPath] & [fileName], type text),
    // Create a properly URL-encoded file URL by encoding each component separately
    // This ensures special characters in directory names and file names are properly handled
    AddCustomColumn3 = Table.AddColumn(
        AddCustomColum2,
        "fileUrl",
        each
            MIS_Digital_Evolution_url
                & "/"
                & Uri.EscapeDataString(BookableResourceCharacteristicDirectory)
                & "/"
                & Uri.EscapeDataString([directoryName])
                & "/"
                & Uri.EscapeDataString([fileName]),
        type text
    ),
    // Extract file size from the Attributes column and convert to kilobytes
    // Uses try/otherwise to handle cases where the Size attribute might be missing
    AddCustomColumn4 = Table.AddColumn(
        AddCustomColumn3, "size.kb", each try Int64.From([Attributes][Size]) otherwise 0, Int64.Type
    ),
    // Filter out files that have no actual data (size is 0 or negative) as well no clear url
    // This ensures we only process files that contain meaningful content
    #"Remove files with no data" = Table.SelectRows(
        AddCustomColumn4, each [size.kb] > 0 and [fileUrl] <> null and [fileUrl] <> ""
    ),
    // Add a count column with value 1 for each row to enable counting operations
    // This is useful for aggregation and summary calculations in downstream processes
    AddCountColumn = Table.AddColumn(#"Remove files with no data", "count", each 1, Int64.Type),
    // Remove reference-type columns that are not needed for the final dataset
    // This includes complex data types like tables, records, lists, and binary data
    // that may cause issues in downstream systems or are simply not required
    RemoveReferenceAttributes = Table.RemoveColumns(
        AddCountColumn,
        Table.ColumnsOfType(
            AddCountColumn, {type table, type record, type list, type nullable binary, type binary, type function}
        )
    )
in
    RemoveReferenceAttributes
