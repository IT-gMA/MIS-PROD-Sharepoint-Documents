# Monadelphous Resource Management & Training Compliance Dataflow

## Project Overview

This is a **Power Query (M language) dataflow project** that extracts, transforms, and processes data from **SharePoint document libraries** for Monadelphous's resource management and training compliance system. The project connects to `https://monadelphous.sharepoint.com/sites/MIS_Digital_Evolution` to process Bookable Resource Characteristic documents and integrate with Power Platform dataflows.

### Core Purpose

- **Resource Management**: Process Bookable Resource Characteristic documents from SharePoint
- **Training Compliance**: Calculate and track training expiry status and compliance
- **Data Integration**: Connect to Power Platform dataflows for entity access and reporting

## Architecture & Components

### Data Sources & Connections

- **Primary Source**: SharePoint Files via `SharePoint.Files(MIS_Digital_Evolution_url, [ApiVersion = 15])`
- **Power Platform Integration**: `PowerPlatform.Dataflows([])` for workspace/dataflow/entity access
- **Configuration**: Parameters stored in `.txt` files (URLs, workspace IDs, directory paths)
- **Entity Pattern**: Each `.m` file represents a dataflow component with specific transformation logic

### Key Domain Areas

1. **Document Processing** (`ResourceCharacteristicDocumentSharepointDirectoryPaths.m`): Extracts SharePoint document metadata and links to resource characteristics
2. **Utility Functions** (`Functions/`): Reusable Power Query transformations for data cleaning and compliance calculations
3. **Training Compliance**: Functions to calculate expiry categories, compliance flags, and days until expiry
4. **Date/Time Utilities**: Week-of-year calculations and bulk date processing

## Project Structure

The complete project structure is documented in [project_structure.txt](project_structure.txt).

## Core Functionality

### Document Processing Pattern

```powerquery
// Standard SharePoint document processing pattern
let
    ParentDirectoryFullPath = MIS_Digital_Evolution_url & "/" & BookableResourceCharacteristicDirectory & "/",
    Source = SharePoint.Files(MIS_Digital_Evolution_url, [ApiVersion = 15]),
    NavigateToParentDirectory = Table.SelectRows(
        Source, each Text.StartsWith([Folder Path], ParentDirectoryFullPath)
    ),
    // Extract UID from directory name (format: something_UID)
    AddJoinKey = Table.AddColumn(
        NavigateToParentDirectory,
        "_bkch.uid",
        each try List.Last(Text.Split([directoryName], "_")) otherwise null,
        type nullable text
    )
in
    Result
```

### Key Utilities

- **Text Processing**: `NullifyBlankString()` for consistent null handling
- **Bulk Transformations**: `BulkInvokeNullifyBlankString()` for multiple columns
- **Date Calculations**: `GetWeekOfYear()` with ISO week standards (Monday start)
- **Compliance Logic**: `GetExpiryCategory()` and `GetCompliancyFlag()` for training status

## Configuration

### Parameter Files

All configuration is stored in the `Parameters/` directory:

- **MIS_Digital_Evolution_url.txt**: SharePoint site URL
- **BookableResourceCharacteristicDirectory.txt**: Directory path for resource documents
- **D365DataflowWorkspaceId.txt**: Power Platform workspace ID
- **MIS_PROD_EntitiesDataflowId.txt**: Entities dataflow ID
- **TrainingComplianceDataflowId.txt**: Training compliance dataflow ID

### Power Platform Integration

- **Workspace ID**: `43cc2a04-dc0c-4d2d-9465-5cde37fcaea2`
- **Dataflow IDs**:
  - Entities: `af5b86be-ba33-47f1-9292-43bac92e84b2`
  - Training Compliance: `e78c1341-c581-47a8-862c-f0a482b67af5`

## Compliance Calculations

### Expiry Categories

The system implements 8 expiry categories from "Compliant" to "Unknown" with specific day thresholds:

1. **Compliant**: Expiry date is more than 365 days in the future
2. **Due Soon**: Expiry date is within 365 days but more than 180 days
3. **Due Very Soon**: Expiry date is within 180 days but more than 90 days
4. **Due Imminently**: Expiry date is within 90 days but more than 30 days
5. **Expired**: Expiry date is more than 30 days past due
6. **Very Expired**: Expiry date is more than 90 days past due
7. **Extremely Expired**: Expiry date is more than 180 days past due
8. **Unknown**: No expiry date available

### Compliance Logic

The `GetCompliancyFlag` function returns a boolean based on the expiry category, marking records as compliant or non-compliant according to business rules.

## Development Workflow

### Adding New Document Processing

1. Create new `.m` file in appropriate location
2. Reference parameter files for URLs and directory paths
3. Use `SharePoint.Files()` with proper API version
4. Implement directory navigation and file filtering
5. Extract business keys from file/directory names when needed
6. Apply data cleaning functions from `Functions/` directory

### Common Operations

- **Text Processing**: Use `NullifyBlankString()` for consistent null handling
- **Bulk Transformations**: Use `BulkInvokeNullifyBlankString()` for multiple columns
- **Date Calculations**: Use `GetWeekOfYear()` with ISO week standards
- **Compliance Logic**: Use `GetExpiryCategory()` and `GetCompliancyFlag()`

## Testing & Validation

- Use parameter files to test with different SharePoint directories
- Validate UID extraction logic with sample directory names
- Test compliance calculations with edge cases (null dates, boundary conditions)
- Verify SharePoint API version compatibility

## Troubleshooting

### Common Issues

- **SharePoint Connection**: Verify `MIS_Digital_Evolution_url` and API version compatibility
- **Directory Navigation**: Check `BookableResourceCharacteristicDirectory` path structure
- **UID Extraction**: Validate directory name format matches extraction logic
- **Compliance Calculations**: Test with edge cases (null dates, boundary day values)
- **Power Platform Links**: Verify workspace and dataflow IDs are current

## Contribution Guidelines

### Code Style

- **Naming Conventions**: PascalCase for files, snake_case for parameters
- **Functions**: Descriptive names with clear purpose
- **Comments**: Document complex logic and business rules

### Pull Request Process

1. Fork the repository
2. Create a feature branch (`feature/ameaningfulname`)
3. Implement changes with proper documentation
4. Submit a pull request with detailed description
5. Address review comments and merge

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or issues, please contact the Monadelphous MIS team or open an issue in the repository.