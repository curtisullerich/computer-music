from rtcmix import *
rtsetparams(44100, 2)
load("STRUM2")

def man():
  dur = 1.0
  amp = 10000
  squish = 1
  decay = 1.0
  pan1 = .1
  pan2 = .5
  pan3 = .9

  pattern1 = bjorklund(16, 5)
  pattern2 = bjorklund(17, 7)
  pattern3 = bjorklund( 5, 2)

  st = 0
  for i in range(1000):
    if (pattern1[i % len(pattern1)] == 1):
      pitch = 7
      STRUM2(st, dur, amp, pitch, squish, decay, pan1)
    if (pattern2[i % len(pattern2)] == 1):
      pitch = 8
      STRUM2(st, dur, amp, pitch, squish, decay, pan2)
    if (pattern3[i % len(pattern3)] == 1):
      pitch = 9
      STRUM2(st, dur, amp, pitch, squish, decay, pan3)
    st += .15

#implementation copyright (c) 2011 Brian House
def bjorklund(steps, pulses):
    steps = int(steps)
    pulses = int(pulses)
    if pulses > steps:
        raise ValueError    
    pattern = []    
    counts = []
    remainders = []
    divisor = steps - pulses
    remainders.append(pulses)
    level = 0
    while True:
        counts.append(divisor / remainders[level])
        remainders.append(divisor % remainders[level])
        divisor = remainders[level]
        level = level + 1
        if remainders[level] <= 1:
            break
    counts.append(divisor)
    
    def build(level):
        if level == -1:
            pattern.append(0)
        elif level == -2:
            pattern.append(1)         
        else:
            for i in xrange(0, counts[level]):
                build(level - 1)
            if remainders[level] != 0:
                build(level - 2)
    
    build(level)
    i = pattern.index(1)
    pattern = pattern[i:] + pattern[0:i]
    return pattern
    
    
man()
