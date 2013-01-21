from rtcmix import *
rtsetparams(44100, 2)
load("STRUM2")

pitches = (7.07, 7.09, 7.10, 8.00, 8.02, 8.03, 8.05, 8.07, 8.09)
plength = len(pitches)
dur = 1.0
amp = 10000
squish = 1
decay = 1.0

st = 0
for i in range(1000):
    pchindex = int(trand(plength))
    pitch = pitches[pchindex]
    pan = random()
    STRUM2(st, dur, amp, pitch, squish, decay, pan)
    st += irand(0.01, 0.3)
