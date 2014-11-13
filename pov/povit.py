#!/usr/bin/env python
from string import Template
pov = file("tmpl.pov").read()
sphere = file("sphere.pov").read()
povt = Template(pov)
spheret = Template(sphere)
lines = file("50.txt").readlines()
out = []
for line in lines:
    line = line.strip()
    strs = line.split(" ")
    out.append([strs[0],strs[1],strs[2],strs[3]])

pd = dict(spheres="")
for i in xrange(0,len(out)):
    fname = "50povs/{:04}.pov".format(i)
    nsphere = out[i]
    x,y,z = nsphere[1],nsphere[2],nsphere[3]
    pd["lx"] = str(x)
    pd["ly"] = str(y)
    pd["lz"] = str(z)
    pd["spheres"] += spheret.substitute({"x":x,"y":y,"z":z})
    if i%1 == 0:
        f = file(fname,"w")
        f.write(povt.substitute(pd))
        f.close()
