rtsetparams(44100, 2)
load("STRUM")

pitches = { 7.07, 7.09, 7.10, 8.00, 8.02, 8.03, 8.05, 8.07, 8.09 }
plength = len(pitches)

st = 0
for (i = 0; i < 1000; i = i+1)
{
  pchindex = trunc(irand(0, plength))
  pitch = pitches[pchindex]
  START(st, 1.0, pitch, 1.0, 0.1, 10000, 1, random())
  st = st + irand(0.01, 0.3)
}
