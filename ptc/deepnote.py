import random
ys = set()
t1 = 100
t2 = 150
for i in range(30):
  x = random.randint(55,68)
  y = 12 * random.randint(1, 10)
  ys |= {y}
  print str(10000000+x) + ", 0 " + str(x) + " " + str(t1) + " " + str(y) + ";"
for y in ys:
  print str(20000000+y) + ", " + str(t1) + " " + str(y) + " " + str(t2) + " " + str(y) + ";"