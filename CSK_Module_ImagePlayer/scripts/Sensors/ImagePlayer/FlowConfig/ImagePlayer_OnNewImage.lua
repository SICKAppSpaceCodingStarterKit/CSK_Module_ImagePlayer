-- Block namespace
local BLOCK_NAMESPACE = "ImagePlayer_FC.OnNewImage"
local nameOfModule = 'CSK_ImagePlayer'

-- Timer to start image provdider
local tmrStartProvider = Timer.create()
tmrStartProvider:setExpirationTime(3000)
tmrStartProvider:setPeriodic(false)

--- Function to start image timer
local function startImageTimer()
  CSK_ImagePlayer.startProvider()
end
Timer.register(tmrStartProvider, "OnExpired", startImageTimer)

--*************************************************************
--*************************************************************

local function register(handle, _ , callback)

  Container.remove(handle, "CB_Function")
  Container.add(handle, "CB_Function", callback)

  local imageType = Container.get(handle, 'ImageType')
  local cycleTime = Container.get(handle, 'CycleTime')
  local path = Container.get(handle, 'Path')

  if imageType ~= '' then
    CSK_ImagePlayer.setImageType(imageType)
  end

  if cycleTime ~= '' then
    local time = tonumber(cycleTime)
    if time then
      CSK_ImagePlayer.setCycleTime(time)
    end
  end

  if path ~= '' then
    CSK_ImagePlayer.setPath(path)
  end

  local function localCallback()
    if callback ~= nil then
      Script.callFunction(callback, 'CSK_ImagePlayer.OnNewImage')
    else
      _G.logger:warning(nameOfModule .. ": " .. BLOCK_NAMESPACE .. ".CB_Function missing!")
    end
  end
  Script.register('CSK_FlowConfig.OnNewFlowConfig', localCallback)

  tmrStartProvider:start()

  return true
end
Script.serveFunction(BLOCK_NAMESPACE ..".register", register)

--*************************************************************
--*************************************************************

local function create(path, imageType, cycleTime)
  local container = Container.create()
  Container.add(container, "Path", path or "")
  Container.add(container, "ImageType", imageType or "")
  Container.add(container, "CycleTime", cycleTime or "")
  Container.add(container, "CB_Function", "")
  return(container)
end
Script.serveFunction(BLOCK_NAMESPACE .. ".create", create)