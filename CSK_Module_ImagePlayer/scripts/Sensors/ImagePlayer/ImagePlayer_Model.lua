---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_ImagePlayer'

local imagePlayer_Model = {}

-- Check if CSK_UserManagement module can be used if wanted
imagePlayer_Model.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

-- Check if CSK_PersistentData module can be used if wanted
imagePlayer_Model.persistentModuleAvailable = CSK_PersistentData ~= nil or false

-- Default values for persistent data
-- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
imagePlayer_Model.parametersName = 'CSK_ImagePlayer_Parameter' -- name of parameter dataset to be used for this module
imagePlayer_Model.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

-- Load script to communicate with the ImagePlayer_Model interface and give access
-- to the ImagePlayer_Model object.
-- Check / edit this script to see/edit functions which communicate with the UI
local setImagePlayer_ModelHandle = require('Sensors/ImagePlayer/ImagePlayer_Controller')
setImagePlayer_ModelHandle(imagePlayer_Model)

--Loading helper functions if needed
imagePlayer_Model.helperFuncs = require('Sensors/ImagePlayer/helper/funcs')
if _G.availableAPIs.specific == true then
  imagePlayer_Model.provider = Image.Provider.Directory.create() -- Directory Provider to play images
end

imagePlayer_Model.viewerID = 'ImgPlayerViewer' -- viewerID
if _G.availableAPIs.specific == true then
  imagePlayer_Model.viewer = View.create(imagePlayer_Model.viewerID) -- Viewer to show images in UI
end
imagePlayer_Model.playerActive = false -- Is directory provider currently active playing images
imagePlayer_Model.styleForUI = 'None' -- Optional parameter to set UI style
imagePlayer_Model.version = Engine.getCurrentAppVersion() -- Version of module

-- Available source paths for files like '/public', '/ram', 'sdcard/0'
imagePlayer_Model.availableSources = Engine.getEnumValues('MountedDrives')
if not imagePlayer_Model.availableSources then
  imagePlayer_Model.availableSources = {}
end
table.insert(imagePlayer_Model.availableSources, '/public')
table.insert(imagePlayer_Model.availableSources, '/resources')
imagePlayer_Model.listOfFolders = ''
imagePlayer_Model.selectedFileSource = '/resources' -- File source selected out of list

-- Parameters to be saved permanently if wanted
imagePlayer_Model.parameters = {}
imagePlayer_Model.parameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
imagePlayer_Model.parameters.viewerActive = false -- Images should be shown in UI viewer
imagePlayer_Model.parameters.path = 'resources/CSK_Module_ImagePlayer/ColorPins'-- Path to images like 'public/images'
imagePlayer_Model.parameters.dataTypes = 'jpg' --'jpg, JPG, bmp, BMP, png, PNG' -- Image type to load
imagePlayer_Model.parameters.cycleTime = 1000 -- Loading new images after x [ms]
imagePlayer_Model.parameters.forwardImage = true -- Should loaded images be forwarded to other modules via "OnNewImage" event
imagePlayer_Model.parameters.imagePoolSize = 50 -- Image pool size to load images
imagePlayer_Model.parameters.resizeFactor = 1.0 -- Resize factor to scale images

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on UI style change
local function handleOnStyleChanged(theme)
  imagePlayer_Model.styleForUI = theme
  Script.notifyEvent("ImagePlayer_OnNewStatusCSKStyle", imagePlayer_Model.styleForUI)
end
Script.register('CSK_PersistentData.OnNewStatusCSKStyle', handleOnStyleChanged)

--- Function to setup directory image provider
local function setup()
  imagePlayer_Model.provider:setPath(imagePlayer_Model.parameters.path, imagePlayer_Model.parameters.dataTypes)
  imagePlayer_Model.provider:setCycleTime(imagePlayer_Model.parameters.cycleTime)
  imagePlayer_Model.provider:setCyclicModeActive(true)
  imagePlayer_Model.provider:setImagePoolSizeMB(imagePlayer_Model.parameters.imagePoolSize)
end
imagePlayer_Model.setup = setup
if _G.availableAPIs.specific == true then
  imagePlayer_Model.setup()
end

--- Function to process loaded images
---@param image Image The loaded image
---@param sensorData SensorData Supplementary data which belongs to the image
local function handleOnNewImage(image, sensorData)
  _G.logger:fine(nameOfModule .. ': Got new image')

  local resImage = image
  if imagePlayer_Model.parameters.resizeFactor ~= 1.0 then
    -- Resize image
    resImage = Image.resizeScale(image, imagePlayer_Model.parameters.resizeFactor, imagePlayer_Model.parameters.resizeFactor, 'LINEAR')
  end

  if imagePlayer_Model.parameters.forwardImage then
    -- Forward image within event
    Script.notifyEvent('ImagePlayer_OnNewImage', resImage, DateTime.getTimestamp())
  end

  if imagePlayer_Model.parameters.viewerActive then
    imagePlayer_Model.viewer:addImage(resImage)
    imagePlayer_Model.viewer:present()
  end
  Script.releaseObject(image)
  Script.releaseObject(resImage)

end
if _G.availableAPIs.default and _G.availableAPIs.specific == true then
  Image.Provider.Directory.register(imagePlayer_Model.provider, "OnNewImage", handleOnNewImage)
end

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return imagePlayer_Model
