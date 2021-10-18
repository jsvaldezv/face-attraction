s.boot;
Server.killAll;

( // load this first - synth def
SynthDef(\harpsi, {
	arg outbus = 0, freq = 440, ffreq = 2, amp = 1, gate = 1, release = 1;
	var out;
	freq = freq * Rand(1, 1.005);
	out = EnvGen.ar(Env.adsr(releaseTime:release), gate, doneAction: Done.freeSelf)
	* amp * Pulse.ar([freq,freq*1.005]/1, 0.25, mul:0.75 );
	out = out * [Rand(0.0, 1.0), Rand(0.0, 1.0)];
	out = RLPF.ar(out, freq * (ffreq / 4) + 1 );
	Out.ar(outbus, out);
}).add;
)

//MOVER CEJAS
//MOVER BOCA
// MOVER CABEZA


( // then run this - sequence
TempoClock.default.tempo = 1.4;
~scale = Scale.new(#[0,2,4,5,7,8,10],tuning: \pythagorean, name: "hijaz");
p = Pbind(
	\instrument, \harpsi,
	\root, -12,
	\scale, ~scale,
	\ffreq, Pseq(((1..2) ++ (3..1)),inf),
	\degree, Pseq([
		Pseries({ rrand(0, 7) }, { ([1,2]).choose }, { rrand(4, 8) }),
		Pseries({ rrand(0, 7) }, {([1,2]).choose}, { rrand(4, 8) }),
		Pseries({ rrand(7, 14) }, 0-{([1,2]).choose}, { rrand(4, 8) })
	], inf),
	\release, Prand([5,6,7,8],inf),
	\dur, Prand((1..8)/4, inf),
	\amp, Prand(((1..8)/8)+1, inf)
).play;
)

p = Synth(\harpsi);
p.set(\freq,100);
p.set(\ffreq,13);


(
SynthDef(\ecos,{|reset 0, amp 0.4, res 2, freq 100|
	var play;
	//En lugar del MouseY iría freq y recibe la instrucción desde Processing
	play =  MoogFF.ar([WhiteNoise.ar(0.2)], MouseY.kr(100, 10000,1), MouseX.kr(0.01, 3,1),reset) !2;
	//play =  MoogFF.ar([WhiteNoise.ar(0.2),PlayBuf.ar(2,1,1,doneAction:2)], freq, res,reset) !2;
	Out.ar(0,play*amp);
}).add
)

n= Synth(\ecos);

n.set(\amp,1);

(
o= OSCdef(\bounce, {arg msg, time, addr, recvPort;
	var cut, amp;

	[msg,time,addr,recvPort].postln;

	cut = msg[1];
	amp = msg[2];

	Synth(\ecos,[\freq, cut,\amp,amp]);
},'\kontrol',nil);
)

//////////////////////////////////////////////