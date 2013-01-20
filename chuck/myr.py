from myro.osc.OSC import *
from myro.chuck import *
import time

initChuck()
s = SineWave()
s.connect()
time.sleep(2)
s.disconnect()

