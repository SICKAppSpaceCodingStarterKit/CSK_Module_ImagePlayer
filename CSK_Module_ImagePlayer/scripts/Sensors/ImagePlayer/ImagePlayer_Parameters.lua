---@diagnostic disable: redundant-parameter, undefined-global

--***************************************************************
-- Inside of this script, you will find the relevant parameters
-- for this module and its default values
--***************************************************************

local functions = {}

local function getParameters()

  local imagePlayerParameters = {}

  imagePlayerParameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
  imagePlayerParameters.viewerActive = false -- Images should be shown in UI viewer
  imagePlayerParameters.path = 'resources/CSK_Module_ImagePlayer/ColorPins'-- Path to images like 'public/images'
  imagePlayerParameters.dataTypes = 'jpg' --'jpg, JPG, bmp, BMP, png, PNG' -- Image type to load
  imagePlayerParameters.cycleTime = 1000 -- Loading new images after x [ms]
  imagePlayerParameters.forwardImage = true -- Should loaded images be forwarded to other modules via "OnNewImage" event
  imagePlayerParameters.imagePoolSize = 50 -- Image pool size to load images
  imagePlayerParameters.resizeFactor = 1.0 -- Resize factor to scale images

  return imagePlayerParameters
end
functions.getParameters = getParameters

return functions