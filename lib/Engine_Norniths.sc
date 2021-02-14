// CroneEngine_Nornith
// pulse wave with perc envelopes, triggered on freq, just polyperc with an attack param
Engine_Nornith : CroneEngine {
	var pg;
    var amp=0.3;
    var release=0.5;
    var attack=0;
    var pw=0.5;
    var cutoff=1000;
    var gain=2;
    var pan = 0;
    var osc1Level = 1;
    var osc2Level = 0;
    var osc2Detune = 0;
    var osc1Type = 0;
    var osc2Type = 0;


	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		pg = ParGroup.tail(context.xg);
    SynthDef("Nornith", {
			arg out, freq = 440, pw=pw, amp=amp, cutoff=cutoff, gain=gain, release=release, attack=attack, pan=pan, osc1Level=osc1Level, osc2Level=osc2Level, osc2Detune=osc2Detune, osc1Type=osc1Type, osc2Type=osc2Type;
			var osc2freq = freq * (1.059463094359**osc2Detune);
			var osc1Array = [
			  Pulse.ar(freq, pw, osc1Level),
			  LFSaw.ar(freq, pw, osc1Level),
			  LFTri.ar(freq, pw, osc1Level),
			  Blip.ar(freq, pw*15, osc1Level),
			  PMOsc.ar(freq, osc2freq*2, pw*3, 0, osc1Level)
			  ];
			var osc1 = Select.ar(osc1Type, osc1Array);
			var osc2Array = [
			  Pulse.ar(osc2freq, 0.5, osc2Level),
			  Saw.ar(osc2freq, osc2Level)
			  ];
			var osc2 = Select.ar(osc2Type, osc2Array);
			var snd = { osc1 + osc2};
			var filt = MoogFF.ar(snd,cutoff,gain); 
			var env = Env.perc(level: amp, releaseTime: release, attackTime: attack).kr(2);
			Out.ar(out, Pan2.ar((filt*env), pan));
		}).add;

		this.addCommand("hz", "f", { arg msg;
			var val = msg[1];
      Synth("Nornith", [\out, context.out_b, \freq,val,\pw,pw,\amp,amp,\cutoff,cutoff,\gain,gain,\release,release,\attack,attack,\pan,pan,\osc1Level,osc1Level,\osc2Level,osc2Level,\osc2Detune,osc2Detune, \osc1Type,osc1Type, \osc2Type,osc2Type], target:pg);
		});

		this.addCommand("amp", "f", { arg msg;
			amp = msg[1];
		});

		this.addCommand("pw", "f", { arg msg;
			pw = msg[1];
		});
		
		this.addCommand("release", "f", { arg msg;
			postln("release: " ++ msg[1]);
			release = msg[1];
		});
		
		this.addCommand("attack", "f", { arg msg;
			postln("attack: " ++ msg[1]);
			attack = msg[1];
		});
		
		this.addCommand("cutoff", "f", { arg msg;
			cutoff = msg[1];
		});
		
		this.addCommand("gain", "f", { arg msg;
			gain = msg[1];
		});
		
		this.addCommand("pan", "f", { arg msg;

			pan = msg[1];
		});
	  this.addCommand("osc1Level", "f", { arg msg;

			osc1Level = msg[1];
		});
		this.addCommand("osc2Level", "f", { arg msg;

			osc2Level = msg[1];
		});
		this.addCommand("osc2Detune", "f", { arg msg;

			osc2Detune = msg[1];
		});
		this.addCommand("osc1Type", "f", { arg msg;

			osc1Type = msg[1];
		});
		this.addCommand("osc2Type", "f", { arg msg;

			osc2Type = msg[1];
		});
	}
}
