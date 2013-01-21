from rtcmix import *
from metalib import *
import math
import random
#print_off()
rtsetparams(44100, 2)
load("STRUM2")
load("MSAXOFONY")

"""
An implementation of Steve Reich's "Piano Phase."
This can have very different output between STRUM2 and MSAXOFONY, sog try both

From chapter 14 of "Notes from the Metalevel."
"""

#trope = [e4, fs, b, cs5, d, fs4, e, cs5, b4, fs, d5, cs5]
trope = [54, 56, 61, 63, 60, 56, 54, 63, 61, 56, 64, 63 ]

def piano1 (trope, stay, move, amp):
  """Generates the score for piano 1 of Reich's 'Piano Phase'"""
  tlen = len(trope)
  cycs = tlen
  reps = tlen * (stay+move) * cycs
  coda = stay*tlen
  pulse = 1./24.
  tempo = 72
  rate = rhythmToSeconds(pulse, tempo)
  dur = rate * 1.5
  timepoint = 0
  for i in range(reps+coda):
    k = trope[i%tlen]
    
    #p0 = output start time (seconds)
    #p1 = duration (seconds)
    #p2 = (absolute, for 16-bit soundfiles: 0-32768)
    #p3 = frequency (Hz)
    #p4 = noise gain (0.0-1.0)
    #p5 = max pressure (0.0-1.0)
    #p6 = reed stiffness (0.0-1.0)
    #p7 = reed aperture (0.0-1.0)
    #p8 = blow position (0.0-1.0)
    #p9 = pan (0-1 stereo; 0.5 is middle) [optional; default is 0.5]
    #p10 = breath pressure table [optional; default is 1.0]
    STRUM2(timepoint, dur, amp, keynumToHertz(k), 1, 1.0, 0.5)
    #MSAXOFONY(timepoint, dur, amp, keynumToHertz(k), .5, .5, .5, .5, .5, .3)
    timepoint += rate

def tempocurve(tlen, stay, move):
  """defines a tempo curve of length tlen, with stay iterations and move iterations"""
  p = tlen * move
  n = 1 + tlen*move
  l1 = []
  for i in range(tlen*stay):
    l1.append(1)
  l2 = []
  for i in range(1 + tlen*move):
    l2.append(float(p)/float(n))
  return l1 + l2

def piano2(trope, stay, move, amp):
  """Generates the score for piano 2 of Reich's 'Piano Phase'"""
  tlen = len(trope)
  cycs = tlen
  coda = stay*tlen#ends with unison segment
  curve = tempocurve(tlen, stay, move)
  clen = len(curve)
  pulse = 1./24.
  tempo = 72
  rate = rhythmToSeconds(pulse, tempo)
  dur = rate*1.5
  timepoint = 0
  for i in range(clen*cycs + coda):
    k = trope[i%tlen]
    c = curve[i%clen]
    STRUM2(timepoint, dur, amp, keynumToHertz(k), 1, 1.0, 0.5)
    #MSAXOFONY(timepoint, dur, amp, keynumToHertz(k), .5, .5, .5, .5, .5, .8)
    timepoint += rate*c

#40 second duration. Increase 'move' to 8 for a 3 minute piece
piano1(trope, 1, 2, 10000)
piano2(trope, 1, 2, 10000)
#print tempocurve(3,1,1)

