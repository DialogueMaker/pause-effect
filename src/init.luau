--!strict
-- This effect pauses a message for a certain amount of time.
-- This is helpful for when you want to draw emphasis to some text.
-- 
-- Programmer: Christian Toney
-- © 2025 Dialogue Maker Group

local packages = script.Parent.roblox_packages;
local Effect = require(packages.effect);
local DialogueMakerTypes = require(packages.dialogue_maker_types);

type Bounds = DialogueMakerTypes.Bounds;
type Effect = DialogueMakerTypes.Effect;
type ContinuePageFunction = DialogueMakerTypes.ContinuePageFunction;
type ExecutionProperties = DialogueMakerTypes.ExecutionProperties;
type Page = DialogueMakerTypes.Page;

local PauseEffect = {};

function PauseEffect.new(timeSeconds: number): Effect

  local function run(self: Effect, executionProperties: ExecutionProperties)

    if executionProperties.shouldSkip then

      executionProperties.continuePage();
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

    if executionProperties.skipPageEvent then

      skipPageThread = task.spawn(function()
      
        executionProperties.skipPageEvent.Event:Wait();
        task.cancel(timeExpiredThread);
        continueEvent:Fire();

      end);
      
    end;

    continueEvent.Event:Wait();
    executionProperties.continuePage();

  end;
  
  local effect = Effect.new({
    name = "PauseEffect";
    run = run;
  });

  return effect;

end;

return PauseEffect;