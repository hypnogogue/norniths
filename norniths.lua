-- an ascension 
-- of singing norniths
--
-- e1 - span
-- e2 - velocity *divison
-- e3 - diversity
-- k1 - *
-- k2 - clarity
-- k3 - inspiration
--
-- based on crow's first
-- by trent gill
-- gfx based on tweetcart
-- by @alexis_lessard/@eigen
-- norns adaption by @shoggoth


scale  = { {0,2,4,7,9}, {0,2,4,5,7,9,11} }
decay  = 0.4
attack = 0.04
spread=1
alt=false
note_num = 64
step_div = 4
in_2_sim = 0
dev = true
attack_type = 2
screen.aa(1)
ghost_num=2
note_history = {}
clock_display_timer=0
reseed_display_timer=0


engine.name='Nornith'
MusicUtil = require "musicutil"
include('lib/p8')

function set_d(t) 
  decay = (t-1)/8 + 0.05 
  decay = util.clamp(decay,0.1,3.2)
end
function set_a(t) 
  attack = (t-1)/64 + ((attack_type==1 and -1) or (attack_type==2 and 0.01) or 1) 
  attack = util.clamp(attack,0,3.2)  
end

function play(out,ix)
  -- play rhythm
  if rhythm[ix][ step[ix] ] & 8 == 8 then
    if ix == 1 then 
      set_d(t[ix]) 
      engine.release(decay)
      --print('decay '..decay)
    else 
      set_a(t[ix]) 
      engine.attack(attack)
      --print('attack '..attack)
    end
    t[ix] = 0
    if out == 1 then
      engine.pan(-spread)
    elseif out == 3 then
      engine.pan(spread)
    end
   --- crow specific: output[out+1]()
  end
  -- set note
  if rhythm[ix+2][ step[ix+2] ] & 8 == 8 then
    n1 = notes[ix][ step[ix+2] ]
    --print('n1 '..n1)

    n2 = notes[ix][ step[ix] ]
   --print('n2 '..n2) 
  ---  abs = math.abs(input[2].volts)/5
    abs = math.abs(in_2_sim)/5
    ---print('abs '..abs)
    note = n1 + abs*(n2-n1)
    ---print('note '..note)
    note = math.floor(note * (abs*3 + 0.1))
    ---print('note '..note)
   --- s = scale[input[2].volts > -0.04 and 1 or 2]
    s = scale[in_2_sim > -0.04 and 1 or 2]

    nn = s[ note%(#s) + 1 ]

    --print('nn '..nn)
    oct = math.floor(note/12) * 12
    --print('oct '..oct)
   --- output[out].volts = nn/12 + oct
   note_num = util.clamp(nn + oct + 70,0,127)
  -- print('note_num '..note_num)
  note_history[note_num]=1
   local freq = MusicUtil.note_num_to_freq(note_num)
  -- print('freq'..freq)
   engine.hz(freq)
  -- redraw(note_num,out)
  end
  step[ix] = (step[ix] % length[ix]) + 1
  step[ix+2] = (step[ix+2] % length[ix+2]) + 1
end

--input[1].change = function(s)
 -- play(1,1)
--  play(3,2)
--end

sd = 0
function lcg(seed)
  local s = seed or sd
  sd = (1103515245*s + 12345) % (1<<31)
  return sd
end

function get_d() return decay end
function get_a() return attack end

t = {0,0}
function env(count)
  for i=1,2 do t[i] = t[i] + 1 end
end

function unique_id()
  uuid=os.time()
  print ('uuid '..uuid)
  return uuid
end

function reseed()
  t = {0,0}
  length = {}
  rhythm = {}
  notes  = {}
  step   = {}
  decay  = 0.4
  attack = 0.04
  -- generate unique tables
  lcg(unique_id())
  lcg()
  lcg()
  lcg()

  for i=1,4 do
    length[i] = lcg()%19 + 6
    rhythm[i] = {}
    for n=1,32 do
      rhythm[i][n] = lcg()
    end
    step[i] = 1
  end

  -- notes
  for i=1,4 do
    notes[i] = {0}
    for n=1,31 do
      notes[i][n+1] = notes[i][n] + (lcg() % 7) -3
    end
  end
end

function init()
  reseed()

  -- crow specific: out params
---  output[1].slew   = 0
---  output[1].volts  = 0
---  output[2].action = ar(get_a,get_d)
---  output[3].slew   = 0.01
---  output[3].volts  = 0
---  output[4].action = ar(get_a,get_d)

  -- start sequence!
 --- crow specific: input[1]{ mode = 'change', direction = 'rising' }
  ghost_setup()
  dec = metro.init{ event = env, time = 0.1 }
  dec:start()
  clock_id = clock.run(forever)
end

play_cnt=0

function forever()
  while true do
    clock.sync(1/32)
    play_cnt=play_cnt+1
    if play_cnt == step_div then
      play(1,1)
      play(3,2)
      play_cnt = 0 
    end
    redraw()
  end
end

function key(n,z)
  if n==3 and z==1 then
    reseed()
    reseed_display_timer=100
  elseif n==1 and z==1 then
    alt=true
  elseif n==1 and z==0 then
    alt=false
  elseif n==2 and z==1 then
    attack_type = attack_type+1
    if attack_type > 3 then attack_type = 1 end
  end
  print(z)
end

function enc(n, delta)
  if n==1 then
    spread = util.clamp(spread+(delta*0.01),0,1)
  elseif n==2 then
      if alt==false then
      if params:get("clock_tempo") <=5 and delta < 0 then return end  
      params:delta("clock_tempo", delta)
      clock_display_timer=20
      else
        step_div=util.clamp(step_div-delta,1,16)
        play_cnt=0
      end
  elseif n==3 then
    in_2_sim = util.clamp(in_2_sim+(delta*0.1),-7,7)
    ghost_num = util.clamp(math.floor(math.abs(in_2_sim*3)),2,20)
    print(ghost_num)
    cls()
    ghost_setup()
  end
end

function rerun()
  norns.script.load(norns.state.script)
end


function ghost_setup()
  k=127
  tt=0
  p={}
  n=ghost_num
  r=rnd
  
  for i=1,n do
   -- NB: color/level adjustment for stronger contrast
   -- p[i]={r(k),r(171),1+r(n)/20,5+5*i}
   local col = flr(1+(i-1) * 15 / n)
   p[i]={r(k),r(171),1+r(n)/20,col}
  end
end



function redraw()
 if attack_type ~= 3 then --trails for smear-y notes
     cls()
  end
 for j=1,n do
  o=p[j]
  h=o[3]*tt+j/9
  x=o[1]+sin(h)*20
  y=-20+(o[2]-tt*99)%171
  for i=0,3 do
   circfill(x+sin(h-i/9)*i,y+1+i*2,6-i,o[4])
   circfill(x+sin(h-i/9)*i,y+i*2,6-i,o[4])
   circfill(x+sin(h-i/9)*i,y-i*2,6-i,o[4])
  end
    if attack_type ==1 then --dot "noise" when notes are percussive
      circfill(x+math.random(-5,5)+sin(h-1/9),y+2*2,math.random(1,3),in_2_sim < 0 and 1 or 0)
      circfill(x+math.random(-5,5)+sin(h-1/9),y*2,math.random(1,2),in_2_sim < 0 and 1 or 0)
      circfill(x+math.random(-5,5)+sin(h-1/9),y-1*2,2,in_2_sim < 0 and 1 or 0)
    elseif attack_type ==2 then --larger floaty dots on standard envelopes
      circfill(x+math.random(-5,5)+sin(h-1/9),y*2,5,in_2_sim < 0 and 1 or 0)
    end
    if clock_display_timer > 0 then
      screen.move(64,64)
      screen.level(1)
      screen.line_width(1)
      screen.line(params:get("clock_tempo"),0)
      screen.stroke()
      print('tempo'..params:get("clock_tempo"))
      screen.update()
      clock_display_timer=clock_display_timer-1
    end
    if reseed_display_timer > 0 then
      circfill(math.random(30,90),30,20,reseed_display_timer / 6)
      circfill(math.random(30,90),math.random(25,35),5,0)
      circfill(math.random(30,90),math.random(25,35),5,0)
      reseed_display_timer = reseed_display_timer-1
    end
      
  end
 flip()
 tt = tt + 0.01
 --print(tablelength(note_history))
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
  
  