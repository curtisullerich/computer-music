from rtcmix import *
from metalib import *
import math
import random
#print_off()
rtsetparams(44100, 2)
load("STRUM2")

"""
from Chapter 18 (Randomness and Chance Composition) of Notes from the Metalevel
"""

def playran(length, rate, key1, key2):
  timepoint = 0
  for i in range(length):
    #see the python docs for a variety of non-uniform random distributions
    r = max(random.random(), random.random()) #this is high-pass
    k = rescale (r, 0.0, 1.0, key1, key2)
    STRUM2(timepoint, rate, 10000, keynumToHertz(k), 1, 1.0, 0.5)
    timepoint += rate
    
#playran(100, .1, 20, 100)


    
drunk = Drunk(50, 5, 40, 80, -1, 10)

#print str(drunk.getList(20))

"""at this point, I got excited about Markov chains and moved on."""


