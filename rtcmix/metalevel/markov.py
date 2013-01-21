from rtcmix import *
from metalib import *
import math
import random
from map import *
#print_off()
rtsetparams(44100, 2)
load("STRUM2")

"""
from Chapter 19 (Markov Processes) of Notes from the Metalevel
"""

#both are valid dictionary instantiations
rhydict  = dict(
q=dict(q=.5,e=2,ed=.75),
e=dict(e=3,q=1),
ed=dict(s=1),s=dict(e=2,q=1)
)
rhydict2 = dict(
q=dict(q=.5,e=2,ed=.75,w=.2),
e=dict(e=3,q=1),ed=dict(s=1),
s=dict(e=2,q=1),
w=dict(stop=1)
)
rhydict3 = dict(
q=dict(q=.5,e=2,ed=1.5,w=.2),
e=dict(e=2.5,q=1),
ed=dict(s=1,ed=.3),
s=dict(e=2,q=1,s=3),
w=dict(stop=1)
)
intmix   = {
1:{3:.4,4:.4,6:.1},
2:{2:.2,3:.4,4:.4,6:.1},
3:{1:.2,2:.6,4:.4},
4:{2:.2,3:.4,4:.4},
6:{2:.4,3:.2,4:.2}
}
intmix2  = {
4: {4:.2,7:.5,12:.3},
7: {4:.1,7:.1,12:.1},
12:{4:.2,7:.3,12:.4}
}

def markovRhythms(length, quarterNote, tbl):
  """
  Uses markov chains to generate rhythms for a drunk sequence of notes
  Use rhytable  for the first exercise from Metalevel
  and rhytable2 for the second exercise. This function works for both.
  """
  r =  'q'
  drunk = Drunk(60, 6, 40, 80, 3, 10)
  timepoint = 0
  amp = 10000
  pulse = quarterNote
  count = 0
  for i in range(length):
    k = drunk.next()
    r = selectNextFromDict(tbl, r)
    print "r=" + str(r)
    dur = pulse
    if r == 'q':
      dur = pulse
    elif r == 'e':
      dur = pulse/2.
    elif r == 'ed':
      dur = pulse / 2.
      dur = dur * 1.5
    elif r == 's':
      dur = pulse / 4.
    elif r == 'w':
      return
    STRUM2(timepoint, pulse, amp, keynumToHertz(k), 1, 1.0, 0.5)
    timepoint += dur

def markovChorder(length, intmix, note, size, ud, rhy, dur, begin):
  """
  Uses markov chains to play a sequence of chords.
  """
  intt = begin
  key = note
  chord = False
  timepoint = 0
  for i in range(length):
    intt = selectNextFromDict(intmix, intt)
    if (random.random() < ud):
      key += intt
      if (key > 90):
        key = 90
    else:
      key -= intt
      if (key < 50):
        key = 50
    chord = []
    for i in range(size):
      n = key
      intt = selectNextFromDict(intmix, intt)
      n = n - intt
      chord.append(n)    
    for c in chord:
      STRUM2(timepoint, dur, 10000, keynumToHertz(c), 1, 1.0, 0.5)    
    timepoint += rhy

def selectNextFromDict(table, past):
  """
  select the next element of the markov transition table
  dictionary implementation given the past value
  """  
  lesum = 0
  print "past: " + str(past)
  print "dict: " + str(table.get(past))

  if table[past] == {}:
    return ()

  for val in table[past].values():
    lesum += val
  print "lesum: " + str(lesum)
  r = random.uniform(0, lesum)

  rsum = 0
  for key,val in table[past].items():
    rsum += val
    print "(key,val): (" + str(key) + "," + str(val) + ")"
    print "is %f < %f?" % (r, rsum)
    if (r < rsum):
      print "return " + str(key)
      return key

  raise Exception("didn't work!")
  #return table.items().pop()

bwintervals = {
0:{0:.5, 1:.2, 2:2., 3:.1, 4:1.5,5:1., 6:.1 ,7:.5, 8:.1, 9:.5, 10:.1, 11:.5},
1:{0:.2, 1:.5, 2:.2, 3:2., 4:1., 5:.1, 6:1.5,7:.1, 8:1., 9:.1, 10:1., 11:.1},
2:{0:2., 1:.2, 2:.5, 3:.2, 4:2., 5:1.5,6:.1, 7:1., 8:.1, 9:.5, 10:.1, 11:.1},
3:{0:.1, 1:2., 2:.2, 3:.5, 4:.2, 5:.1, 6:1.5,7:.1, 8:1., 9:.1, 10:.5, 11:.1},
4:{0:1.5,1:.1, 2:2., 3:.2, 4:.5, 5:2., 6:.2, 7:1.5,8:.1, 9:1., 10:.1, 11:.5},
5:{0:1., 1:.1, 2:1.5,3:.2, 4:2., 5:.5, 6:.2, 7:2., 8:.1, 9:1.5,10:.1, 11:1.},
6:{0:.1, 1:1.5,2:.1, 3:2., 4:.1, 5:.2, 6:.5, 7:.2, 8:2., 9:.1, 10:1.5,11:.1},
7:{0:.5, 1:.1, 2:1., 3:.1, 4:1.5,5:2., 6:.2, 7:.5, 8:.2, 9:2., 10:.1, 11:1.5},
8:{0:.1, 1:1., 2:.1, 3:1.5,4:.1, 5:.1, 6:2., 7:.2, 8:.5, 9:.2, 10:2., 11:.1},
9:{0:.5, 1:.1, 2:.4, 3:.1, 4:1., 5:1.5,6:.1, 7:2., 8:.2, 9:.5, 10:.2, 11:2.},
10:{0:.1,1:.5, 2:.1, 3:1., 4:.1, 5:.1, 6:1.5,7:.1, 8:2., 9:.2, 10:.5, 11:.2},
11:{0:.5,1:.1, 2:.5, 3:.1, 4:.5, 5:1., 6:.1, 7:1.5,8:.1, 9:2., 10:.2, 11:.5},
}

bwoctaves = {
'c3':{'c3':2., 'c4':1., 'c5':.5, 'c6':.25},
'c4':{'c3':1., 'c4':2., 'c5':1., 'c6':.5},
'c5':{'c3':.5, 'c4':1., 'c5':2., 'c6':1.},
'c6':{'c3':.25,'c4':.5, 'c5':1., 'c6':2.}
}
bwoctaves2 = {
48:{48:2., 60:1., 72:.5, 84:.25},
60:{48:1., 60:2., 72:1., 84:.5},
72:{48:.5, 60:1., 72:2., 84:1.},
84:{48:.25,60:.5, 72:1., 84:2.}
}

def bw(length, octave, rate, octaves, intervals):
  """markov texture example"""
  reps = 0
  interval = 0
  timepoint = 0
  dur = rate*1.5
  for i in range(length):
    if reps == 0:
      reps = random.choice([4,8,12,16])
      octave = selectNextFromDict(octaves, octave)
    interval = selectNextFromDict(intervals, interval)#random.choice([0,1,2,3,4,5,6,7,8,9,10,11])
    STRUM2(timepoint, dur, 10000, keynumToHertz(octave + interval), 1, 1.0, 0.5)
    timepoint += rate
    reps -= 1

#I really need to implement a note name parser
bdaynames = ['c4', 'c', 'd', 'c', 'f', 'e', 'c', 'c', 'd', 'c', 'g', 'f', 'c', 'c', 'c5', 'a4', 'f', 'e', 'd', 'bf', 'bf', 'a', 'f', 'g', 'f']
bday =      [  60,  60,  62,  60,  65,  64,  60,  60,  62,  60,  67,  65,  60,  60,   72,   69,  65,  63,  62,   70,   70,  69,  65,  67, 65]
amazinggracenames = ['G', 'C', 'C', 'E', 'D', 'C', 'E', 'E', 'D', 'C', 'A', 'G', 'G', 'C', 'C', 'E', 'D', 'C', 'E', 'D', 'E', 'G', 'E', 'G', 'G', 'E', 'D', 'C', 'E', 'E', 'D', 'C', 'A', 'G', 'G', 'G', 'C', 'C', 'E', 'D', 'C', 'E', 'D', 'C']
grace = [67, 60, 60, 64, 62, 60, 64, 64, 62, 60, 69, 67, 67, 60, 60, 64, 62, 60, 64, 62, 64, 67, 64, 67, 67, 64, 62, 60, 64, 64, 62, 60, 69, 67, 67, 67, 60, 60, 64, 62, 60, 64, 62, 60]

thing = ['e5', 'e5', 'd5', 'c5', 'c5', 'd5', 'd5', 'e5', 'd5', 'c5', 'g5', 'g5', 'f5', 'e5', 'e5', 'd5', 'c5', 'd5', 'e5', 'c5']
thingint = []
for note in thing:
  thingint.append(nameToNum(note))

thing2 = ['C4', 'E4', 'C4', 'E4', 'D#4', 'C4', 'E4', 'C4', 'E4', 'D#4', 'E4', 'C4', 'E4', 'D#4', 'E4', 'C4', 'E4', 'D#4', 'C4', 'E4']
thingint2 = []
for note in thing2:
  thingint2.append(nameToNum(note))


def playnotes(seq, rate):
  """Simple function that plays a sequence of notes (given as keynumbers)."""
  timepoint = 0
  dur = rate * 1.5
  for note in seq:
    STRUM2(timepoint, dur, 10000, keynumToHertz(note), 1, 1.0, 0.5)
    timepoint += rate

#playnotes(thingint, .5)

def markovanalyzeZerothOrder(seq, order):
  """This is a basic implementation of zeroth-order markov chaining
  that could be more helpful in understanding how it works for
  a more complex application. """
  pat = dict()
  for i in range(len(seq)-1):
    if (seq[i] in pat):
      d = pat[seq[i]]
      if (seq[i+1] in d):
        d[seq[i+1]] = d[seq[i+1]]+1
      else:
        d[seq[i+1]] = 1
      pat[seq[i]] = d
    else:
      pat[seq[i]] =  {seq[i+1]:1}
  last = seq[len(seq)-1]
  if (last not in pat):
    pat[last] = {}
  return pat

def markovanalyze(seq, order):
  """Performs nth-order markov chaining. Returns a dictionary of dictionaries
  dictionaries that hold the occurrence counts for each note pattern and *not*
  the actual probabilities. Use selectNextFromDict(...) to choose the next note 
  using the weighted probabilities.
  
  Examples:
  
  markovanalyze([1,2,1,2,3],0)
  {
  (2,): {1: 1, 3: 1}, 
  (3,): {}, 
  (1,): {2: 2}
  }

  markovanalyze([1,2,1,2,3],1)
  {
  (1, 2): {1: 1, 3: 1}, 
  (2, 3): {}, 
  (2, 1): {2: 1}
  }
  
  markovanalyze([1,2,1,2,3],4)
  {
  (1, 2, 1, 2, 3): {}
  }
  """
  order += 1 # I originally thought 0th-order was actually 1st-order. Oops.
  if (order > len(seq)):
    raise Exception("Order was larger than sequence. You can't do that.")

  pat = dict() 
  #prev = tuple(seq[0:order])
  
  for i in range(len(seq)-order):
    #if the dict is in our table
    currentkey = tuple(seq[i:i+order])

    #if the dict contains the note /after/ this key
    note = seq[i+order]

    if (currentkey in pat):
      
      #get dict for this key
      d = pat[currentkey]

      if (note in d):
        #update that element's count by 1
        d[note] = d[note]+1
      else:
        #add the note to the dict with count of 1
        d[note] = 1
      #place that updated dict in the table for the current key
      pat[currentkey] = d
    else:
      #create a new dict containing just the next note and freq 1
      pat[currentkey] =  {note:1}

  #grab the last sequence (because no note follows it)
  last = tuple(seq[len(seq)-order:])
  #if it's not in the table already, add it, so we can terminate if this is reached
  if (last not in pat):
    pat[last] = {}
  return pat

def playbday(order, reps, rate, pat, dur):
  first = random.randint(0, len(pat)-(order+1))
  past = pat[first:first+order+1]
  #print "first: %i len(pat): %i order: %i" % (first, len(pat), order)
  #print "past: " + str(past)
  table = markovanalyze(pat, order)
  #print table
  #print "reps: " + str(reps)
  timepoint = 0
  
  for i in range(reps):
  
    nextkey = tuple(past[len(past)-(order+1):])
    #print "nextkey: " + str(nextkey)
    note = selectNextFromDict(table, nextkey)
    if (note == ()): #hit the end of the line
      return
    #print "note to play: " + str(note)
    past.append(note)
    #print "updated past: " + str(past)
    STRUM2(timepoint, dur, 10000, keynumToHertz(note), 1, 1.0, 0.5)
    timepoint = timepoint + rate
    
#change the seed to anything, or remove it. It's just nice to have consistent results
random.seed(1)
#markovRhythms(100, .4, rhydict)
#markovRhythms(100, .4, rhydict2)
#markovRhythms(100, .4, rhydict3)
#markovChorder(25, intmix,  60, 6, .6, 1.2, 1.2, 1)
#markovChorder(25, intmix2, 60, 6, .6, .6, 1, 4)
#bw(120, 60, .125, bwoctaves2, bwintervals)
#bw(120, 48, .125, bwoctaves2, bwintervals)

#together
#bw(120, 60, .125, bwoctaves2, bwintervals)
#bw(120 * 21/13, 48, .125, bwoctaves2, bwintervals)

#together
#bw(120, 60, .125, bwoctaves2, bwintervals)
#bw(120*21/13, 48, .125*13./21., bwoctaves2, bwintervals)

#playbday(0, 25, .5, bday, .75)
#playbday(0, 25, .5, grace, .75)
#playbday(0, 50, .4, thingint, 1)
#playbday(0, 1000, .04, thingint, 1)
#playbday(0, 50, .2, thingint, 1)
#playbday(1, 50, .2, thingint, 1)
#playbday(2, 50, .2, thingint, 1)
playbday(1, 50, .2, thingint2, 1)

#print markovanalyzeFirstOrder([1,2,1,2,3],1)
#print markovanalyze([1,2,1,2,3],0)  

