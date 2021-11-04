s.boot;
Server.killAll;

//************************** FIRST SYNTH ***************************//
// EJECUTAR
(
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

// EJECUTAR
h = Synth(\harpsi);

// EJECUTAR
(
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

// EJECUTAR
p = Synth(\harpsi);

//************************** SECOND SYNTH ***************************//
// EJECUTAR
(
SynthDef(\ecos,{|reset 0, amp 0.4, res 2, freq 100|
	var play;

	play =  MoogFF.ar([WhiteNoise.ar(0.2)], freq, res,reset) !2;

	Out.ar(0,play*amp);
}).add
)

// EJECUTAR
n = Synth(\ecos);

//************************** OSC DEF ***************************//
// EJECUTAR SOLO SI ES EN LINEA
// JESUS IP
// m = NetAddr("22.55.80.116", 57120); // local machine
// MISA IP
// m = NetAddr("25.57.148.229", 57120); // local machine

// EJECUTAR
(
o = OSCdef(\points, {arg msg, time, addr, recvPort;
	var cut, amp, freqOne, freqTwo;

	[msg,time,addr,recvPort].postln;

	cut = msg[1];
	amp = msg[2];
	freqOne = msg[3];
	freqTwo = msg[4];

	n.set(\freq, cut, \amp, amp);
	h.set(\freq, freqOne, \ffsreq, freqTwo);

},'\points',nil);
)