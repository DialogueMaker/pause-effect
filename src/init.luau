--!strict
-- This effect pauses a message for a certain amount of time.
-- This is helpful for when you want to draw emphasis to some text.
-- 
-- Programmer: Christian Toney
-- © 2025 Dialogue Maker Group

local packages = script.Parent.roblox_packages;
local Effect = require(packages.effect);
local DialogueMakerTypes = require(packages.dialogue_maker_types);

type ExecutionProperties = DialogueMakerTypes.ExecutionProperties;
type RunEffectFunction = DialogueMakerTypes.RunEffectFunction;

local PauseEffect = {};

function PauseEffect.new(timeSeconds: number)

  local run: RunEffectFunction = function(self, executionProperties): ()

    if executionProperties.shouldSkip then

      executionProperties.onCompleted();
      return;
      
    end;
      
    local continueEvent = Instance.new("BindableEvent");
    local skipPageThread: thread? = nil;
    local timeExpiredThread = task.delay(timeSeconds, function()
      
      if skipPageThread then
        
        task.cancel(skipPageThread);

      end;
      continueEvent:Fire();

    end);

    skipPageThread = task.spawn(function()
    
      executionProperties.skipPageSignal:Wait();
      task.cancel(timeExpiredThread);
      continueEvent:Fire();

    end);

    continueEvent.Event:Wait();
    executionProperties.onCompleted();

  end;
  
  local effect = Effect.new({
    name = "PauseEffect";
    run = run;
  });

  return effect;

end;

return PauseEffect;