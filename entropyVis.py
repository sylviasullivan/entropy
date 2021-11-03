#!/bin/envs/ncplot
from mpl_toolkits.mplot3d import Axes3D
import numpy as np, csv, sys
import matplotlib.pyplot as plt
import matplotlib.cm as cm

times = np.reshape(np.repeat(np.arange(1,175),191),[174,191])
space = np.transpose(np.reshape(np.repeat(np.arange(2,193),174),[191,174]))
Hvals = np.zeros((times.shape))
fH = 'entropy_ocean_D576_T305' 

with open(fH,'rb') as csvfile:
     fH2 = csv.reader(csvfile,delimiter=' ')
     for row in fH2:
         row2 = [ii for ii in row if ii]
         row2 = row2[1:]
         Hvals[fH2.line_num-1,:] = row2

print(times.shape)
print(space.shape)
print(Hvals.shape)


fig = plt.figure(figsize=(12,9))
ax = fig.add_subplot(111,projection='3d')
ax.plot_surface(times,space,Hvals,cmap=cm.summer,linewidth=0,antialiased=False,rstride=1,cstride=1)
ax.set_xlabel('Time [hrs]',fontsize=12)
ax.set_ylabel('Neighborhood extent [grid cells]',fontsize=12)
ax.set_zlabel('Information entropy [bits]',fontsize=12)
ax.view_init(30,40+180)
plt.tick_params(labelsize=11)
fig.savefig('Hsurf_ocean_D576_T305_rotate.pdf',bbox_inches='tight')
plt.show()


# rotate the axes and update
#for angle in np.linspace(0, 360, 10):
#    ax.view_init(30, angle)
#    print(angle)
#    plt.draw()
#    plt.pause(5)
