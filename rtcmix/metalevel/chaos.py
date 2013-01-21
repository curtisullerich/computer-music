from rtcmix import *
from metalib import *
import math
import random
#print_off()
rtsetparams(44100, 2)
load("STRUM2")

"""
from Chapter 17 (Sonification of Chaos) of Notes from the Metalevel
"""

#produce a chaotic melody
def logmap (chaos, length, rate, dur, key1, key2, amp):
  y = random.random()
  k = 0
  timepoint = 0
  for i in range(length):
    y = y * chaos * (1 - y)
    k = rescale(y, 0, 1, key1, key2)
    STRUM2(timepoint, dur, amp, keynumToHertz(k), 1, 1.0, 0.5)
    timepoint = timepoint+rate

#produce a chaotic rhythm
def groove(chaos, length, pulse):
  y = random.random()
  timepoint = 0
  for i in range(length):
    y = y * chaos * (1 - y)
    STRUM2(timepoint, pulse, 10000, keynumToHertz(60), 1, 1.0, 0.5)
    timepoint = timepoint + (pulse * y)

def logmap2d(chaos, length, pulse, key1, key2, dur):
  y = random.random()
  timepoint = 0
  for i in range(length):
    y = y * chaos * (1 - y)
    STRUM2(timepoint, dur, 10000, keynumToHertz(rescale(y, 0, 1, key1, key2)), 1, 1.0, 0.5)
    timepoint = timepoint + round(rescale(y, 0, 1, 0, pulse), 1)

#produce a melody based on the Henon Map
def henon1(length, rate, dur, key1, key2):
  x = 0
  y = 0
  timepoint = 0
  for i in range(length):
    z = (y+1) - (.2 * x * x)
    y = .99 * x
    STRUM2(timepoint, dur, 10000, keynumToHertz(rescale(y, -5, 5, key1, key2)), 1, 1.0, 0.5)
    timepoint = timepoint + rescale(z, -5, 5, 0, rate)
    x = z
    
#produce a melody based on the Henon Map
def henon2(length, rate, key1, key2):
  x = 0
  y = 0
  k = 0
  r = 0
  timepoint = 0
  for i in range(length):
    z = (y+1) - (.2 * x * x)
    y = .99 * x
    k = rescale(y, -5, 5, key1, key2)
    r = rescale(z, -5, 5, 0, .4)
    STRUM2(timepoint, r, 10000, keynumToHertz(k), 1, 1.0, 0.5)
    STRUM2(timepoint+rate, 0.05, rescale(.6, 0, 1, 0, 12000), keynumToHertz(k), 1, 1.0, 0.5)
    timepoint = timepoint + (rate + r)
    x = z    

#Use whatever you want. this just allows for consistent results for testing variations
random.seed(1)

"""some defaults for you to try"""
#logmap(3.7, 200, .125, .25, 60, 96, 10000)
#logmap(3.99, 200, .125, .25, 60, 96, 10000)
#groove(3.99, 50, 0.5)
#logmap2d(3.99, 200, .125, 60, 96, .2)
#henon1(250, .25, 1, 48, 84)
#henon2(250, .25, 48, 84)

