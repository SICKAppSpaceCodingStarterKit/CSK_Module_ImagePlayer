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

Script.serveEvent('CSK_ImagePlayer.OnNewStatusModuleVersion', 'ImagePlayer_OnNewStatusModuleVersion')
Script.serveEvent('CSK_ImagePlayer.OnNewStatusCSKStyle', 'ImagePlayer_OnNewStatusCSKStyle')
Script.serveEvent('CSK_ImagePlayer.OnNewStatusModuleIsActive', 'ImagePlayer_OnNewStatusModuleIsActive')

Script.serveEvent("CSK_ImagePlayer.OnNewStatusViewerActive", "ImagePlayer_OnNewStatusViewerActive")
Script.serveEvent("CSK_ImagePlayer.OnNewCycleTime", "ImagePlayer_OnNewCycleTime")
Script.serveEvent("CSK_ImagePlayer.OnNewImage", "ImagePlayer_OnNewImage")
Script.serveEvent("CSK_ImagePlayer.OnNewResizeFactor", "ImagePlayer_OnNewResizeFactor")

Script.serveEvent('CSK_ImagePlayer.OnNewImageSizeToShare', 'ImagePlayer_OnNewImageSizeToShare')
Script.serveEvent("CSK_ImagePlayer.OnNewStatusForwardImage", "ImagePlayer_OnNewStatusForwardImage")
Script.serveEvent("CSK_ImagePlayer.OnPlayerActive", "ImagePlayer_OnPlayerActive")
Script.serveEvent('CSK_ImagePlayer.OnNewStatusFolderList', 'ImagePlayer_OnNewStatusFolderList')
Script.serveEvent("CSK_ImagePlayer.OnNewPath", "ImagePlayer_OnNewPath")
Script.serveEvent("CSK_ImagePlayer.OnNewImageType", "ImagePlayer_OnNewImageType")

Script.serveEvent('CSK_ImagePlayer.OnNewStatusFlowConfigPriority', 'ImagePlayer_OnNewStatusFlowConfigPriority')
Script.serveEvent("CSK_ImagePlayer.OnDataLoadedOnReboot", "ImagePlayer_OnDataLoadedOnReboot")
Script.serveEvent("CSK_ImagePlayer.OnNewStatusLoadParameterOnReboot", "ImagePlayer_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_ImagePlayer.OnPersistentDataModuleAvailable", "ImagePlayer_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_ImagePlayer.OnNewParameterName", "ImagePlayer_OnNewParameterName")

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

local function checkIfFolder(path, list)
  local listOfContent = File.list(path)
  if listOfContent then
    for key, value in pairs(listOfContent) do
      local isFolder = File.isdir(path .. '/' .. value)
      if isFolder then
        local pathName = path .. '/' .. value
        list[pathName] = pathName
        checkIfFolder(pathName, list)
      end
    end
  end
  return list
end

local function updateFolderList()
  local listOfFolders = {}
  for key, value in pairs(imagePlayer_Model.availableSources) do
    listOfFolders[value] = value
    listOfFolders = checkIfFolder(value, listOfFolders)
  end
  imagePlayer_Model.listOfFolders = listOfFolders
end

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
  updateFolderList()

  Script.notifyEvent("ImagePlayer_OnNewStatusModuleVersion", 'v' .. imagePlayer_Model.version)
  Script.notifyEvent("ImagePlayer_OnNewStatusCSKStyle", imagePlayer_Model.styleForUI)
  Script.notifyEvent("ImagePlayer_OnNewStatusModuleIsActive", _G.availableAPIs.default and _G.availableAPIs.specific)

  Script.notifyEvent("ImagePlayer_OnNewStatusViewerActive", imagePlayer_Model.parameters.viewerActive)
  Script.notifyEvent("ImagePlayer_OnNewCycleTime", imagePlayer_Model.parameters.cycleTime)
  Script.notifyEvent("ImagePlayer_OnNewResizeFactor", imagePlayer_Model.parameters.resizeFactor)
  Script.notifyEvent("ImagePlayer_OnNewStatusForwardImage", imagePlayer_Model.parameters.forwardImage)

  Script.notifyEvent("ImagePlayer_OnPlayerActive", imagePlayer_Model.playerActive)
  Script.notifyEvent("ImagePlayer_OnNewStatusFolderList", imagePlayer_Model.helperFuncs.createJsonList(imagePlayer_Model.listOfFolders))
  Script.notifyEvent("ImagePlayer_OnNewPath", imagePlayer_Model.parameters.path)
  Script.notifyEvent("ImagePlayer_OnNewImageType", imagePlayer_Model.parameters.dataTypes)

  Script.notifyEvent("ImagePlayer_OnNewStatusFlowConfigPriority", imagePlayer_Model.parameters.flowConfigPriority)
  Script.notifyEvent("ImagePlayer_OnNewStatusLoadParameterOnReboot", imagePlayer_Model.parameterLoadOnReboot)
  Script.notifyEvent("ImagePlayer_OnPersistentDataModuleAvailable", imagePlayer_Model.persistentModuleAvailable)
  Script.notifyEvent("ImagePlayer_OnNewParameterName", imagePlayer_Model.parametersName)

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
  _G.logger:fine(nameOfModule .. ": Viewer active = " .. tostring(status))
  if not status then
    imagePlayer_Model.viewer:clear()
    imagePlayer_Model.viewer:present()
  end
end
Script.serveFunction("CSK_ImagePlayer.setViewerActive", setViewerActive)

local function setForwardImage(status)
  _G.logger:fine(nameOfModule .. ": Forward image = " .. tostring(status))
  imagePlayer_Model.parameters.forwardImage = status
end
Script.serveFunction("CSK_ImagePlayer.setForwardImage", setForwardImage)

local function setCycleTime(time)
  imagePlayer_Model.parameters.cycleTime = time
  Image.Provider.Directory.setCycleTime(imagePlayer_Model.provider, time)
  _G.logger:fine(nameOfModule .. ": Set cycle time = " .. tostring(time))
end
Script.serveFunction("CSK_ImagePlayer.setCycleTime", setCycleTime)

local function setPath(path)
  imagePlayer_Model.parameters.path = path
  Image.Provider.Directory.setPath(imagePlayer_Model.provider, path, imagePlayer_Model.parameters.dataTypes)
  _G.logger:fine(nameOfModule .. ": Set path = " .. path)
  Script.notifyEvent('ImagePlayer_OnNewImageSizeToShare', 'CSK_ImagePlayer.OnNewImage')
end
Script.serveFunction("CSK_ImagePlayer.setPath", setPath)

local function setImageType(imgType)
  imagePlayer_Model.parameters.dataTypes = imgType
  Image.Provider.Directory.setPath(imagePlayer_Model.provider, imagePlayer_Model.parameters.path, imagePlayer_Model.parameters.dataTypes)
  _G.logger:fine(nameOfModule .. ": Set image type = " .. imgType)
end
Script.serveFunction("CSK_ImagePlayer.setImageType", setImageType)

local function setResizeFactor(factor)
  imagePlayer_Model.parameters.resizeFactor = factor
  _G.logger:fine(nameOfModule .. ": Set resizeFactor = " .. tostring(factor))
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
  _G.logger:fine(nameOfModule .. ": Trigger player once")
  imagePlayer_Model.provider:start(1)
  imagePlayer_Model.provider:stop()
end
Script.serveFunction("CSK_ImagePlayer.triggerOnce", triggerOnce)

local function getStatusModuleActive()
  return _G.availableAPIs.default and _G.availableAPIs.specific
end
Script.serveFunction('CSK_ImagePlayer.getStatusModuleActive', getStatusModuleActive)

local function clearFlowConfigRelevantConfiguration()
  if imagePlayer_Model.playerActive == true then
    stopProvider()
  end
end
Script.serveFunction('CSK_ImagePlayer.clearFlowConfigRelevantConfiguration', clearFlowConfigRelevantConfiguration)

local function getParameters()
  return imagePlayer_Model.helperFuncs.json.encode(imagePlayer_Model.parameters)
end
Script.serveFunction('CSK_ImagePlayer.getParameters', getParameters)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:fine(nameOfModule .. ": Set new parameter name: " .. name)
  imagePlayer_Model.parametersName = name
end
Script.serveFunction("CSK_ImagePlayer.setParameterName", setParameterName)

local function sendParameters(noDataSave)
  if imagePlayer_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(imagePlayer_Model.helperFuncs.convertTable2Container(imagePlayer_Model.parameters), imagePlayer_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, imagePlayer_Model.parametersName, imagePlayer_Model.parameterLoadOnReboot)
    _G.logger:fine(nameOfModule .. ": Send ImagePlayer parameters with name '" .. imagePlayer_Model.parametersName .. "' to CSK_PersistentData module.")
    if not noDataSave then
      CSK_PersistentData.saveData()
    end
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
      return true
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
      return false
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
    return false
  end
end
Script.serveFunction("CSK_ImagePlayer.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  imagePlayer_Model.parameterLoadOnReboot = status
  _G.logger:fine(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
  Script.notifyEvent("ImagePlayer_OnNewStatusLoadParameterOnReboot", status)
end
Script.serveFunction("CSK_ImagePlayer.setLoadOnReboot", setLoadOnReboot)

local function setFlowConfigPriority(status)
  imagePlayer_Model.parameters.flowConfigPriority = status
  _G.logger:fine(nameOfModule .. ": Set new status of FlowConfig priority: " .. tostring(status))
  Script.notifyEvent("ImagePlayer_OnNewStatusFlowConfigPriority", imagePlayer_Model.parameters.flowConfigPriority)
end
Script.serveFunction('CSK_ImagePlayer.setFlowConfigPriority', setFlowConfigPriority)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if _G.availableAPIs.default and _G.availableAPIs.specific then
    _G.logger:fine(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')

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
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

local function resetModule()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    clearFlowConfigRelevantConfiguration()
    pageCalled()
  end
end
Script.serveFunction('CSK_ImagePlayer.resetModule', resetModule)
Script.register("CSK_PersistentData.OnResetAllModules", resetModule)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setImagePlayer_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

