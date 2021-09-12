s.boot;
// Play it with the mouse...

~path1 =  "/Users/misaelfelix2/Desktop/moog_design.wav"
~buf1 = Buffer.read(s,~path1,bufnum:1);
~buf1.play;
x = { MoogFF.ar([WhiteNoise.ar(0.2),PlayBuf.ar(2,1,1,doneAction:2)], MouseY.kr(100, 10000,1), MouseX.kr(0, 4)) !2 }.play(s);

x.free;

(
SynthDef(\amlo,{|reset 0, amp 0.7, res 2, freq 100|
	var play;
	//En lugar del MouseY iría freq y recibe la instrucción desde Processing
	play =  MoogFF.ar([WhiteNoise.ar(0.2),PlayBuf.ar(2,1,1,doneAction:2)], MouseY.kr(100, 10000,1), res,reset) !2;
	//play =  MoogFF.ar([WhiteNoise.ar(0.2),PlayBuf.ar(2,1,1,doneAction:2)], freq, res,reset) !2;
	Out.ar(0,play*amp);
}).add
)

Synth(\amlo);

(
o= OSCdef(\bounce, {arg msg, time, addr, recvPort;
	var cut, amp;

	[msg,time,addr,recvPort].postln;

	cut = msg[1];
	amp = msg[2];

	Synth(\amlo,[\freq, cut,\amp,amp]);
},'\kontrol',nil);
)

OSCdef.trace(true);
OSCdef.trace(false);