s.boot;
// Play it with the mouse...
x = { MoogFF.ar(WhiteNoise.ar(01.1), MouseY.kr(100, 10000,1), MouseX.kr(0, 4)) !2 }.play(s);
x.free;

{ MoogLadder.ar(Mix(LFSaw.ar([120, 180], 0, 0.33)), LinExp.kr(LFCub.kr(0.1, 0.5*pi), -1, 1, 180, 8500), 0.75).dup }.play
(
o= OSCdef(\bounce, {arg msg, time, addr, recvPort;
	var rt, amp, bn;

	[msg,time,addr,recvPort].postln;

	rt = msg[1];
	amp = msg[2];
	bn = msg[3];
	Synth(\gota,[\rate, rt,\amp,amp,\bn,bn]);
},'\kontrol',nil);
)

OSCdef.trace(true);
OSCdef.trace(false);