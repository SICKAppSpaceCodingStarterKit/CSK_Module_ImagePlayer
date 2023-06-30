---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the ImagePlayer_Model
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_ImagePlayer'

-- Timer to update UI via events after page was loaded
local tmrImagePlayer = Timer.create()
tmrImagePlayer:setExpirationTime(300)
tmrImagePlayer:setPeriodic(false)

-- Reference to global handle
local imagePlayer_Model

-- ************************ UI Events Start ********************************

Script.serveEvent("CSK_ImagePlayer.OnNewStatusLoadParameterOnReboot", "ImagePlayer_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_ImagePlayer.OnPersistentDataModuleAvailable", "ImagePlayer_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_ImagePlayer.OnNewParameterName", "ImagePlayer_OnNewParameterName")

Script.serveEvent("CSK_ImagePlayer.OnNewStatusViewerActive", "ImagePlayer_OnNewStatusViewerActive")
Script.serveEvent("CSK_ImagePlayer.OnNewCycleTime", "ImagePlayer_OnNewCycleTime")
Script.serveEvent("CSK_ImagePlayer.OnNewImage", "ImagePlayer_OnNewImage")
Script.serveEvent("CSK_ImagePlayer.OnNewResizeFactor", "ImagePlayer_OnNewResizeFactor")

Script.serveEvent('CSK_ImagePlayer.OnNewImageSizeToShare', 'ImagePlayer_OnNewImageSizeToShare')
Script.serveEvent("CSK_ImagePlayer.OnNewStatusForwardImage", "ImagePlayer_OnNewStatusForwardImage")
Script.serveEvent("CSK_ImagePlayer.OnPlayerActive", "ImagePlayer_OnPlayerActive")
Script.serveEvent("CSK_ImagePlayer.OnNewPath", "ImagePlayer_OnNewPath")
Script.serveEvent("CSK_ImagePlayer.OnNewImageType", "ImagePlayer_OnNewImageType")
Script.serveEvent("CSK_ImagePlayer.OnDataLoadedOnReboot", "ImagePlayer_OnDataLoadedOnReboot")

Script.serveEvent("CSK_ImagePlayer.OnUserLevelOperatorActive", "ImagePlayer_OnUserLevelOperatorActive")
Script.serveEvent("CSK_ImagePlayer.OnUserLevelMaintenanceActive", "ImagePlayer_OnUserLevelMaintenanceActive")
Script.serveEvent("CSK_ImagePlayer.OnUserLevelServiceActive", "ImagePlayer_OnUserLevelServiceActive")
Script.serveEvent("CSK_ImagePlayer.OnUserLevelAdminActive", "ImagePlayer_OnUserLevelAdminActive")

-- ************************ UI Events End **********************************

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("ImagePlayer_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("ImagePlayer_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("ImagePlayer_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("ImagePlayer_OnUserLevelAdminActive", status)
end

--- Function to get access to the imagePlayer_Model object
---@param handle handle Handle of imagePlayer_Model object
local function setImagePlayer_Model_Handle(handle)
  imagePlayer_Model = handle
  if imagePlayer_Model.userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)
end

--- Function to update user levels
local function updateUserLevel()
  if imagePlayer_Model.userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("ImagePlayer_OnUserLevelOperatorActive", true)
    Script.notifyEvent("ImagePlayer_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("ImagePlayer_OnUserLevelServiceActive", true)
    Script.notifyEvent("ImagePlayer_OnUserLevelAdminActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrImagePlayer()

  updateUserLevel()

  Script.notifyEvent("ImagePlayer_OnNewStatusViewerActive", imagePlayer_Model.parameters.viewerActive)
  Script.notifyEvent("ImagePlayer_OnNewCycleTime", imagePlayer_Model.parameters.cycleTime)
  Script.notifyEvent("ImagePlayer_OnNewResizeFactor", imagePlayer_Model.parameters.resizeFactor)
  Script.notifyEvent("ImagePlayer_OnNewStatusForwardImage", imagePlayer_Model.parameters.forwardImage)
  Script.notifyEvent("ImagePlayer_OnNewStatusLoadParameterOnReboot", imagePlayer_Model.parameterLoadOnReboot)
  Script.notifyEvent("ImagePlayer_OnPersistentDataModuleAvailable", imagePlayer_Model.persistentModuleAvailable)
  Script.notifyEvent("ImagePlayer_OnNewParameterName", imagePlayer_Model.parametersName)
  Script.notifyEvent("ImagePlayer_OnPlayerActive", imagePlayer_Model.playerActive)
  Script.notifyEvent("ImagePlayer_OnNewPath", imagePlayer_Model.parameters.path)
  Script.notifyEvent("ImagePlayer_OnNewImageType", imagePlayer_Model.parameters.dataTypes)

end
Timer.register(tmrImagePlayer, "OnExpired", handleOnExpiredTmrImagePlayer)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrImagePlayer:start()
  return ''
end
Script.serveFunction("CSK_ImagePlayer.pageCalled", pageCalled)

local function setViewerActive(status)
  imagePlayer_Model.parameters.viewerActive = status
  _G.logger:info(nameOfModule .. ": Viewer active = " .. tostring(status))
  if not status then
    imagePlayer_Model.viewer:clear()
    imagePlayer_Model.viewer:present()
  end
end
Script.serveFunction("CSK_ImagePlayer.setViewerActive", setViewerActive)

local function setForwardImage(status)
  _G.logger:info(nameOfModule .. ": Forward image = " .. tostring(status))
  imagePlayer_Model.parameters.forwardImage = status
end
Script.serveFunction("CSK_ImagePlayer.setForwardImage", setForwardImage)

local function setCycleTime(time)
  imagePlayer_Model.parameters.cycleTime = time
  Image.Provider.Directory.setCycleTime(imagePlayer_Model.provider, time)
  _G.logger:info(nameOfModule .. ": Set cycle time = " .. tostring(time))
end
Script.serveFunction("CSK_ImagePlayer.setCycleTime", setCycleTime)

local function setPath(path)
  imagePlayer_Model.parameters.path = path
  Image.Provider.Directory.setPath(imagePlayer_Model.provider, path, imagePlayer_Model.parameters.dataTypes)
  _G.logger:info(nameOfModule .. ": Set path = " .. path)
  Script.notifyEvent('ImagePlayer_OnNewImageSizeToShare', 'CSK_ImagePlayer.OnNewImage')
end
Script.serveFunction("CSK_ImagePlayer.setPath", setPath)

local function setImageType(imgType)
  imagePlayer_Model.parameters.dataTypes = imgType
  Image.Provider.Directory.setPath(imagePlayer_Model.provider, imagePlayer_Model.parameters.path, imagePlayer_Model.parameters.dataTypes)
  _G.logger:info(nameOfModule .. ": Set image type = " .. imgType)
end
Script.serveFunction("CSK_ImagePlayer.setImageType", setImageType)

local function setResizeFactor(factor)
  imagePlayer_Model.parameters.resizeFactor = factor
  _G.logger:info(nameOfModule .. ": Set resizeFactor = " .. tostring(factor))
  Script.notifyEvent('ImagePlayer_OnNewImageSizeToShare', 'CSK_ImagePlayer.OnNewImage')
end
Script.serveFunction("CSK_ImagePlayer.setResizeFactor", setResizeFactor)

local function startProvider()
  imagePlayer_Model.provider:start(0)
  imagePlayer_Model.playerActive = true
  Script.notifyEvent("ImagePlayer_OnPlayerActive", imagePlayer_Model.playerActive)
  _G.logger:info(nameOfModule .. ": Start player")
  Script.notifyEvent('ImagePlayer_OnNewImageSizeToShare', 'CSK_ImagePlayer.OnNewImage')
end
Script.serveFunction("CSK_ImagePlayer.startProvider", startProvider)

local function stopProvider()
  imagePlayer_Model.provider:stop()
  imagePlayer_Model.playerActive = false
  Script.notifyEvent("ImagePlayer_OnPlayerActive", imagePlayer_Model.playerActive)
  _G.logger:info(nameOfModule .. ": Stop player")
end
Script.serveFunction("CSK_ImagePlayer.stopProvider", stopProvider)

local function triggerOnce()
  _G.logger:info(nameOfModule .. ": Trigger player once")
  imagePlayer_Model.provider:start(1)
  imagePlayer_Model.provider:stop()
end
Script.serveFunction("CSK_ImagePlayer.triggerOnce", triggerOnce)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:info(nameOfModule .. ": Set new parameter name: " .. name)
  imagePlayer_Model.parametersName = name
end
Script.serveFunction("CSK_ImagePlayer.setParameterName", setParameterName)

local function sendParameters()
  if imagePlayer_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(imagePlayer_Model.helperFuncs.convertTable2Container(imagePlayer_Model.parameters), imagePlayer_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, imagePlayer_Model.parametersName, imagePlayer_Model.parameterLoadOnReboot)
    _G.logger:info(nameOfModule .. ": Send ImagePlayer parameters with name '" .. imagePlayer_Model.parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_ImagePlayer.sendParameters", sendParameters)

local function loadParameters()
  if imagePlayer_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(imagePlayer_Model.parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")
      imagePlayer_Model.parameters = imagePlayer_Model.helperFuncs.convertContainer2Table(data)
      imagePlayer_Model.setup()
      CSK_ImagePlayer.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_ImagePlayer.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  imagePlayer_Model.parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_ImagePlayer.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  _G.logger:info(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')

  if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

    _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')
    imagePlayer_Model.persistentModuleAvailable = false
  else

    local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule)

    if parameterName then
      imagePlayer_Model.parametersName = parameterName
      imagePlayer_Model.parameterLoadOnReboot = loadOnReboot
    end

    if imagePlayer_Model.parameterLoadOnReboot then
      loadParameters()
    end
    Script.notifyEvent('ImagePlayer_OnDataLoadedOnReboot')
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setImagePlayer_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

