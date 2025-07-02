# ServiceNow Change Management (CHG) Automation Suite

A comprehensive automation toolkit for ServiceNow Change Management operations including creation, status tracking, modification, and automated test execution.

## 🎯 Overview

This repository provides a collection of scripts and tools to automate common ServiceNow Change Management (CHG) operations, reducing manual effort and ensuring consistency across change processes.

## 🚀 Features

- **Change Request Creation** - Automated CHG creation with predefined templates
- **Status Tracking** - Real-time monitoring of change request status and progress
- **Change Modification** - Automated updates to change requests based on business rules
- **Test Automation** - Automated execution of tests related to changes
- **API Integration** - RESTful API interactions with ServiceNow
- **Environment-based Configuration** - Secure credential management using environment variables

## 📋 Prerequisites

- **ServiceNow Instance** - Access to a ServiceNow instance with Change Management module
- **API Access** - REST API access enabled on your ServiceNow instance
- **jq** - JSON processor for parsing API responses
- **curl** - HTTP client for API requests
- **Bash** - Unix shell environment

### Installing Dependencies

#### macOS
```bash
brew install jq
```

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install jq curl
```

#### CentOS/RHEL
```bash
sudo yum install jq curl
```

## 🔧 Setup

### 1. Environment Configuration

Set up your ServiceNow credentials as environment variables:

```bash
export SNOW_INSTANCE="your-instance-name"
export SNOW_USERNAME="your-username"
export SNOW_PASSWORD="your-password"
```

### 2. Script Permissions

Make the scripts executable:

```bash
chmod +x get_chg_details.sh
```

## 📁 Scripts Overview

### `get_chg_details.sh`
Fetches detailed information about a specific change request.

**Usage:**
```bash
SNOW_INSTANCE=your-instance SNOW_USERNAME=admin SNOW_PASSWORD=yourpassword ./get_chg_details.sh CHG0001234
```

**Features:**
- Retrieves comprehensive change request details
- Displays key fields (number, description, state, priority, etc.)
- Shows full JSON response for advanced analysis
- Handles authentication and permission errors gracefully

**Output Fields:**
- Number
- Short Description
- State
- Priority
- Category
- Requested By
- Assigned To
- Created/Updated timestamps
- Start/End dates
- Description
- Justification
- Risk/Impact/Urgency

## 🔄 Planned Features

### Change Request Creation (`create_chg.sh`)
- Automated CHG creation from templates
- Bulk change creation from CSV files
- Integration with approval workflows

### Status Tracking (`track_chg_status.sh`)
- Real-time status monitoring
- Automated notifications on status changes
- Dashboard generation for change overview

### Change Modification (`modify_chg.sh`)
- Automated field updates
- Bulk modifications
- Change request cloning

### Test Automation (`run_chg_tests.sh`)
- Automated test execution for changes
- Integration with CI/CD pipelines
- Test result reporting

## 🛠️ API Endpoints Used

The scripts interact with ServiceNow REST API endpoints:

- **Change Request Table**: `/api/now/table/change_request`
- **Query Parameters**:
  - `sysparm_query` - Filter conditions
  - `sysparm_display_value` - Return display values
  - `sysparm_exclude_reference_link` - Exclude reference links

## 🔒 Security Best Practices

1. **Environment Variables**: Never hardcode credentials in scripts
2. **API Permissions**: Use dedicated service accounts with minimal required permissions
3. **Network Security**: Ensure API access is restricted to authorized networks
4. **Audit Logging**: Monitor API usage and access patterns

## 📊 Error Handling

The scripts include comprehensive error handling for:

- **Authentication Errors** (401) - Invalid credentials
- **Authorization Errors** (403) - Insufficient permissions
- **Not Found Errors** (404) - Invalid instance or resource
- **Validation Errors** - Invalid input parameters
- **Network Errors** - Connection issues

## 🧪 Testing

### Manual Testing
```bash
# Test with a valid change request
SNOW_INSTANCE=your-instance SNOW_USERNAME=admin SNOW_PASSWORD=yourpassword ./get_chg_details.sh CHG0001234

# Test error handling with invalid change
SNOW_INSTANCE=your-instance SNOW_USERNAME=admin SNOW_PASSWORD=yourpassword ./get_chg_details.sh INVALID123
```

### Automated Testing
Future versions will include:
- Unit tests for script functions
- Integration tests with ServiceNow APIs
- CI/CD pipeline integration

## 📈 Usage Examples

### Basic Change Request Lookup
```bash
# Set environment variables
export SNOW_INSTANCE="mycompany"
export SNOW_USERNAME="automation.user"
export SNOW_PASSWORD="secure_password"

# Fetch change details
./get_chg_details.sh CHG0001234
```

### Integration with Other Tools
```bash
# Use in CI/CD pipeline
SNOW_INSTANCE=$SNOW_INSTANCE \
SNOW_USERNAME=$SNOW_USERNAME \
SNOW_PASSWORD=$SNOW_PASSWORD \
./get_chg_details.sh $CHANGE_NUMBER > change_details.json
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow bash scripting best practices
- Include error handling for all operations
- Add comprehensive documentation for new scripts
- Test thoroughly before submitting PRs

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Common Issues

**Authentication Failed**
- Verify your ServiceNow credentials
- Check if your account has API access
- Ensure the instance name is correct

**Permission Denied**
- Verify your account has read access to change_request table
- Check if your role includes necessary permissions

**Script Not Found**
- Ensure the script is executable: `chmod +x script_name.sh`
- Verify you're in the correct directory

### Getting Help

- Check the [ServiceNow Developer Documentation](https://developer.servicenow.com/)
- Review ServiceNow API reference for change management
- Open an issue in this repository for bugs or feature requests

## 🔄 Version History

- **v1.0.0** - Initial release with change request details fetching
- **v1.1.0** - Added environment variable support for security
- **Future** - Planned features for creation, modification, and test automation

---

**Note**: This automation suite is designed to work with ServiceNow instances that have Change Management module enabled and REST API access configured.