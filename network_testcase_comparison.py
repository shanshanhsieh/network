from __future__ import division
import numpy as np
import pandas as pd
import cea.globalvar
import cea.inputlocator
import math
from math import *
import os
import matplotlib.pyplot as plt

network = 'network3'
network_type = 'DH'

path_to_matlab = os.path.abspath(r'C:\Users\fcl2\Documents\MATLAB\network\network3_DH\0-1000')
simulink_network_qloss = pd.read_csv(os.path.join(path_to_matlab,'%s_qloss_supply.csv' %network))
simulink_network_dP = pd.read_csv(os.path.join(path_to_matlab, '%s_dP_supply.csv' %network), header= None)
path_to_cea = os.path.abspath(r'C:\reference-case-open\baseline\outputs\data\optimization\network\layout')
cea_network_name = network + '_' + network_type
cea_network = os.path.join(path_to_cea, cea_network_name)
cea_network_qloss = pd.read_csv(os.path.join(cea_network, '%s_qloss_Supply.csv' %network_type))
cea_network_dP = pd.read_csv(os.path.join(cea_network, '%s_P_DeltaP.csv' %network_type))['pressure_loss_supply_Pa']

delta_qloss = cea_network_qloss.sub(simulink_network_qloss)
percent_d_qloss = delta_qloss[0:1000].div(simulink_network_qloss[0:1000])

# delta_ploss = cea_network_dP.sub(simulink_network_dP, axis=0)
delta_ploss = simulink_network_dP.sub(cea_network_dP, axis=0)
percent_d_ploss = delta_ploss[0:1000].div(simulink_network_dP[0:1000])



# plotting
x = np.arange(1000)
#dashes = [10, 5, 100, 5]  # 10 points on, 5 off, 100 on, 5 off

fig1, (ax1,ax2) = plt.subplots(2, sharex=True)
line1, = ax1.plot(x, cea_network_dP[0:1000], label='cea')
line2, = ax1.plot(x, simulink_network_dP[0:1000], label='simulink')
ax1.legend(loc='lower right')

line3, = ax2.plot(x, percent_d_ploss[0:1000], label='d_ploss')
ax2.legend(loc='lower right')



# plt.show()
axs = {}
figs = plt.figure(figsize=(30,20))
figs.subplots_adjust(hspace=1)
for edge in range(simulink_network_qloss.shape[1]):
        plot_number = 811 + edge
        axs[edge]=figs.add_subplot(plot_number)
        column = simulink_network_qloss.columns[edge]
        line3, = axs[edge].plot(x, cea_network_qloss[0:1000][column])
        line4, = axs[edge].plot(x, simulink_network_qloss[0:1000][column])
        #axs[edge].legend(loc='lower right')
        axs[edge].set_title(column)

plt.show()

print percent_d_ploss.describe()
print percent_d_qloss.describe()