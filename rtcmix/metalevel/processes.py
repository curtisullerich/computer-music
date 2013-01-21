from rtcmix import *
from metalib import *
import random
#print_off()
rtsetparams(44100, 2)
load("MSAXOFONY")
load("STRUM2")

"""
Examples from chapter 13 (Algorithms and Processes) of 'Notes from the Metalevel'
"""

def keynumToPC(k):
  return k % 12

def retrograderow(row):
  ret = row[:] #copy it
  ret.reverse()
  return ret

def transposerow(row, to):
  ret = []
  for pc in row:
    ret.append(keynumToPC(pc+to))
  return ret
  
def invertrow(row):
  ret = []
  for pc in row:
    ret.append(keynumToPC(12-pc))
  return ret

row1 = [0,1,6,7,10,11,5,4,3,9,2,8]
row2 = invertrow(row1)
row3 = retrograderow(row1)
row4 = retrograderow(row2)

def strum(key1, key2, rate, dur, amp):
  step = 1
  if (key2 < key1):
    step = -1
  diff = abs(key2-key1)
  
  key = key1
  beg = 0
  for i in range(diff+1):
    #MSAXOFONY(beg, dur, amp, keynumToHertz(key), .5, .5, .5, .5, .5, .5)
    STRUM2(beg, dur, amp, keynumToHertz(key), 1, 1.0, 0.5)
    beg += rate
    key += step
  

def ttone1(reps, row, key, beat, amp):
  timepoint = 0
  for i in range(reps):
    length = len(row)
    p = i%length
    pc = row[p]
    k = key + pc
    MSAXOFONY(timepoint, beat*2, amp, keynumToHertz(k), .5, .5, .5, .5, .5, .5)
    timepoint += beat

def ttone2(length, row, key, beat, amp):
  timepoint = 0
  for i in range(length):
    pc = row[i%12]
    n = key-12
    if (random.random() > .5):
      n += 24
    k = n + pc
    MSAXOFONY(timepoint, beat*2, amp, keynumToHertz(k), .5, .5, .5, .5, .5, .5)
    timepoint += beat


def hitone(knum, at):
  MSAXOFONY(at, at, 10000, keynumToHertz(knum+24), .5, .5, .5, .5, .5, .5)
  
def thump(knum, timepoint):
  MSAXOFONY(timepoint, .5, 9000, keynumToHertz(knum-18), .5, .5, .5, .5, .5, .5)
  MSAXOFONY(timepoint, .5, 9000, keynumToHertz(knum-23), .5, .5, .5, .5, .5, .5)

def riff(knum, rhy, timepoint):
  rate = rhythmToSeconds(rhy/4, 60)
  timepoint = 0
  for k in range((knum%13)+39, ((knum%13)+39)*5,13):
    MSAXOFONY(timepoint, 10, 4000, keynumToHertz(k), .5, .5, .5, .5, .5, .5)
    timepoint += rate
    
def ghosts():
  timepoint = 0
  for i in range(12):
    ahead = (timepoint +.5) * 2
    main = random.randint(53,77)
    high = main >= 65
    amp = 6000
    if (high):
      amp = 9000
    rhy = random.choice([1./16., 1./8., 3./16.])
    MSAXOFONY(timepoint, rhythmToSeconds(rhy, 60), amp, keynumToHertz(main), .5, .5, .5, .5, .5, .5)
    if (high):
      hitone(main, ahead)
      riff(main, rhy, timepoint)
    if (rhy == 3./16.):
      thump(main, timepoint + .5)
    timepoint += rhythmToSeconds(rhy, 60)
 
 
#strum(48, 60, .1, 1, 9000)
#strum(84, 72, .1, 1, 9000)

print row1
print row2
print row3
print row4

#ttone1(36, row1, 60, .2, 10000) 
#ttone2(36, row1, 60, .2, 10000)
  
#hitone(60, 2)
#thump(60, 0)
#riff(60,.125, 0)

#ghosts()
