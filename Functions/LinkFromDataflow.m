let
    LinkFromDataflow = (workspace as text, dataflow as text, entityName as text) as table =>
        let
            FindWorkspace = PowerPlatform.Dataflows([]){[Id = "Workspaces"]}[Data],
            NavigateToWorkspace = FindWorkspace{[workspaceId = workspace]}[Data],
            NavigateToDataflow = NavigateToWorkspace{[dataflowId = dataflow]}[Data],
            FilteredRows = NavigateToDataflow{[entity = entityName]}[Data]
        in
            FilteredRows
in
    LinkFromDataflow
