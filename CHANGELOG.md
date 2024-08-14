# Changelog
All notable changes to this project will be documented in this file.

## Release 3.0.0

### New features
- Supports FlowConfig feature to forward loaded images
- Provide version of module via 'OnNewStatusModuleVersion'
- Function 'getParameters' to provide PersistentData parameters
- Check if features of module can be used on device and provide this via 'OnNewStatusModuleIsActive' event / 'getStatusModuleActive' function
- Function to 'resetModule' to default setup
- Provide new images in /resources

### Improvements
- Provide available folders auto suggestion in UI
- New UI design available (e.g. selectable via CSK_Module_PersistentData v4.1.0 or higher), see 'OnNewStatusCSKStyle'
- 'loadParameters' returns its success
- 'sendParameters' can control if sent data should be saved directly by CSK_Module_PersistentData
- Changed log level of some messages from 'info' to 'fine'
- Added UI icon and browser tab information

## Release 2.4.0

### Improvements
- Using recursive helper functions to convert Container <-> Lua table
- Update to EmmyLua annotations
- Usage of lua diagnostics
- Documentation updates

## Release 2.3.1

### Bugfix
- Fixed wrong parameter for 'relatedEvent' within 'OnNewImageSizeToShare'-event
- Added missing docu

## Release 2.3.0

### Improvements
- Using internal moduleName variable to be usable in merged apps instead of _APPNAME, as this did not work with PersistentData module in merged apps.

## Release 2.2.0

### New features
- Optionally hide content related to CSK_UserManagement
- Sample images added to resources folder

### Improvements
- ParameterName available on UI
- Update of helper funcs to support 4-dim tables for PersistentData
- Loading only required APIs ('LuaLoadAllEngineAPI = false') -> less time for GC needed
- Minor code edits / docu updates

## Release 2.1.0

### New features
- Event "OnNewImageSizeToShare" informs if image size changed, so that other modules can react on this

### Improvements
- Prepared for CSK_UserManagement user levels: Operator, Maintenance, Service, Admin (no influence yet)
- Renamed page folder accordingly to module name
- Updated documentation

## Release 2.0.0

### New features
- Update handling of persistent data according to CSK_PersistentData module ver. 2.0.0

## Release 1.0.0
- Initial commit
