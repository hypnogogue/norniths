  params:add_separator("")
  params:add_separator("- SYNTH -")
  
  OSC1_Types = {"Pulse","Saw","Tri","Blip","PhaseOsc"}
  
  params:add{type = "option", id = "osc1Type", name = "Osc 1 Wave", options = OSC1_Types, default = 1, action = function(value) engine.osc1Type(value - 1) end}
  
    cs_PW = controlspec.new(0,100,'lin',0,50,'%')
  params:add{type="control",id="pw", name="Osc 1 Shape",controlspec=cs_PW,
    action=function(x) engine.pw(x/100) end}
  
  cs_OSC1LVL = controlspec.new(0,1,'lin',0,1,'')
  params:add{type="control",id="osc1Level",name="Osc 1 Level",controlspec=cs_OSC1LVL,
    action=function(x) engine.osc1Level(x) end}

  OSC2_Types = {"Pulse","Saw"}
  
  params:add{type = "option", id = "osc2Type", name = "Osc 2 Wave", options = OSC2_Types, default = 1, action = function(value) engine.osc2Type(value - 1) end}

  cs_OSC2LVL = controlspec.new(0,1,'lin',0,0,'')
  params:add{type="control",id="osc2Level",name="Osc 2 Level",controlspec=cs_OSC2LVL,
    action=function(x) engine.osc2Level(x) end}
  
  cs_OSC2DETUNE = controlspec.new(-12,12,'lin',0.001,0,'')
  params:add{type="control",id="osc2Detune", name="Osc 2 Detune",controlspec=cs_OSC2DETUNE,
    action=function(x) engine.osc2Detune(x) end}

  cs_CUT = controlspec.new(50,5000,'exp',0,1000,'hz')
  params:add{type="control",id="cutoff",name="Cutoff",controlspec=cs_CUT,
    action=function(x) engine.cutoff(x) end}

  cs_GAIN = controlspec.new(0,4,'lin',0,2,'')
  params:add{type="control",id="gain",name="Resonance",controlspec=cs_GAIN,
    action=function(x) engine.gain(x) end}

  cs_ATK = controlspec.new(0,3.2,'lin',0,0,'s')
  params:add{type="control",id="attack",name="Attack",controlspec=ATK,
    action=function(x) engine.attack(x) end}
  
  cs_REL = controlspec.new(0.1,3.2,'lin',0,0.5,'s')
  params:add{type="control",id="release",name="Release",controlspec=cs_REL,
    action=function(x) engine.release(x) end}
  
  cs_AMP = controlspec.new(0,1,'lin',0,0.5,'')
  params:add{type="control",id="amp", name="Amplitude",controlspec=cs_AMP,
    action=function(x) engine.amp(x) end}