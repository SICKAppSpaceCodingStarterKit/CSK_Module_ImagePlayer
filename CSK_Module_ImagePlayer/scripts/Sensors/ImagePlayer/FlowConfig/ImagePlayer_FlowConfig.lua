-- Include all relevant FlowConfig scripts

--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
--*****************************************************************

require('Sensors.ImagePlayer.FlowConfig.ImagePlayer_OnNewImage')

--- Function to react if FlowConfig was updated or stopped
local function handleOnClearOldFlow()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    if imagePlayer_Model.parameters.flowConfigPriority then
      CSK_ImagePlayer.clearFlowConfigRelevantConfiguration()
    end
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)
Script.register('CSK_FlowConfig.OnStopFlowConfigProviders', handleOnStopProvider)