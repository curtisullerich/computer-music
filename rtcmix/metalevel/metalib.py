import math
import random
def rescale(x, oldmin, oldmax, newmin, newmax):
  oldrange = oldmax - oldmin
  newrange = newmax - newmin
  oldsize  = x - oldmin
  return ((newrange/oldrange) * oldsize) + newmin

def keynumToHertz(keynum):
  lowestfreq = 8.175 #C-1
  return lowestfreq * math.pow(2.0, float(keynum)/12.0)

# Intended to complement the Common Music implementation.
# This object allows generation of a list or piece-wise generation of
# a series of random values, constrained by step size and upper and lower bounds.
# Mode allows specification of the method for handling exceeding bounds.
# Avoid allows setting of a step size to avoid. Set it larger than width
# to exclude no extra steps.
class Drunk:
  def __init__(self, _num, _width, _low, _high, _mode, _avoid):
    self.num = _num
    self.cur = self.num
    self.width = _width
    self.low = _low
    self.high = _high
    self.mode = _mode
    self.avoid = _avoid
  
  #Return a list of the given length beginning at this Drunk's current note
  def getList(self, length):
    ret = [self.cur]
    for i in range(length-1):
      ret.append(self.next())
    return ret      
  
  #Advance self.cur by one drunk step and return its value
  def next(self):
    next = self.cur + round(random.uniform(-1*self.width, self.width))
    while (next is self.cur + self.avoid) or (next is self.cur - self.avoid):
      next = self.cur + int(random.uniform(-1*self.width, self.width))
    if (next < self.low) or (next > self.high):
      if (self.mode is -1):
        if (next < self.low):
          next += (self.low - next) * 2
        else:
          next -= (next - self.high) * 2
      elif (self.mode is 0):
        return false
      elif (self.mode is 1):
        if (next < self.low):
          next = self.low
        else:
          next = self.high
      elif (self.mode is 2):
        next = (self.low + self.high) / 2
      elif (self.mode is 3):
        next = int(random.uniform(self.low, self.high))
      else:
        return false
    self.cur = next
    return int(next)

def bpmToSeconds(bpm):
  return 60.0/float(bpm)
  
def rhythmToSeconds(rhy, tempo):
  return rhy * 4.0 * bpmToSeconds(tempo)
