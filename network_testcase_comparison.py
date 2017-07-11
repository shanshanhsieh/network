from __future__ import division
import numpy as np
import pandas as pd
import cea.globalvar
import cea.inputlocator
import math
from math import *
import os
import matplotlib.pyplot as plt

network = 'network2'
network_type = 'DH'
time_start = 0
time_end = 8760

# path_to_matlab = os.path.abspath(r'C:\Users\fcl2\Documents\MATLAB\network\network2_DH_parts')
path_to_matlab = os.path.abspath(r'C:\Users\Shanshan\Documents\GitHub\network\network2_DH_new')
# simulink_network_qloss = pd.read_csv(os.path.join(path_to_matlab,'%s_qloss_supply.csv' %network))
simulink_network_qloss = pd.read_csv(os.path.join(path_to_matlab,'%s_Phi_W_supply.csv' %network))
# simulink_network_Phi_A = pd.read_csv(os.path.join(path_to_matlab,'%s_Phi_A.csv' %network))
simulink_network_dP = pd.read_csv(os.path.join(path_to_matlab, '%s_dP_supply.csv' %network), header= None)


# path_to_cea = os.path.abspath(r'C:\reference-case-open\baseline\outputs\data\optimization\network\layout')
path_to_cea = os.path.abspath(r'C:\Users\Shanshan\Documents\GitHub\network\cea')
# path_to_cea = os.path.abspath(r'C:\Users\fcl2\Documents\MATLAB\network\cea')
cea_network_name = network + '_' + network_type
cea_network = os.path.join(path_to_cea, cea_network_name)
cea_network_qloss = pd.read_csv(os.path.join(cea_network, '%s_qloss_Supply.csv' %network_type))
cea_network_dP = pd.read_csv(os.path.join(cea_network, '%s_P_DeltaP.csv' %network_type))['pressure_loss_supply_Pa']

delta_qloss = cea_network_qloss.sub(simulink_network_qloss)
percent_d_qloss = delta_qloss.div(simulink_network_qloss)*100
# percent_Phi_loss = simulink_network_qloss.div(simulink_network_Phi_A)

# delta_ploss = cea_network_dP.sub(simulink_network_dP, axis=0)
delta_ploss = simulink_network_dP.sub(cea_network_dP, axis=0)
percent_d_ploss = delta_ploss.div(simulink_network_dP)*100

# diff_max_qloss = pd.DataFrame(index=cea_network_qloss.columns, columns=['max_cea_qloss [kW]', 'max_simulink_qloss [kW]', 'diff [%]'])
# for edge in range(cea_network_qloss.shape[1]):
#         e = cea_network_qloss.columns[edge]
#         diff_max_qloss.loc[e,'max_cea_qloss [kW]'] = abs(cea_network_qloss[e].values).max()
#         diff_max_qloss.loc[e,'max_simulink_qloss [kW]'] = abs(simulink_network_qloss[e].values).max()
#         diff_max_qloss.loc[e, 'diff [%]'] = abs(diff_max_qloss.loc[e, 'max_simulink_qloss [kW]'] - diff_max_qloss.loc[e, 'max_simulink_qloss [kW]'])/diff_max_qloss.loc[e, 'max_simulink_qloss [kW]']*100


x = np.arange(time_start, time_end, 1)

diff_total_qloss = []
for t in range(time_end-time_start):
        results = np.zeros(3)
        results[0] = cea_network_qloss.iloc[t,:].values.sum()
        results[1] = simulink_network_qloss.iloc[t,:].values.sum()
        results[2] = abs(cea_network_qloss.iloc[t,:].values.sum() - simulink_network_qloss.iloc[t,:].values.sum())/simulink_network_qloss.iloc[t,:].values.sum()
        diff_total_qloss.append(results)

pd.DataFrame(diff_total_qloss, columns=['cea_qloss_total [kW]', 'simulink_qloss_total [kW]', 'diff']).to_csv(os.path.join(path_to_matlab, '%s_qloss_diff.csv' %network), na_rep='0', index=False, float_format='%.3f')



# plotting
x = np.arange(time_start, time_end, 1)
#dashes = [10, 5, 100, 5]  # 10 points on, 5 off, 100 on, 5 off

fig_ploss, (ax1, ax2) = plt.subplots(2, sharex=True)
line1, = ax1.plot(x, cea_network_dP[time_start:time_end], label='cea')
line2, = ax1.plot(x, simulink_network_dP[time_start:time_end], label='simulink')
ax1.legend(loc='lower right')
ax1.set_ylabel('Pa')


line3, = ax2.plot(x, percent_d_ploss[time_start:time_end], label='d_ploss')
ax2.legend(loc='lower right')
ax2.set_ylim((-20,20))
ax2.set_ylabel('[%]')

fig_ploss.savefig('%s_ploss' %network)


axs = {}
figs_qloss = plt.figure(figsize=(30,20))
figs_qloss.subplots_adjust(hspace=1)
for edge in range(simulink_network_qloss.shape[1]):
        plot_number = 811 + edge
        axs[edge]=figs_qloss.add_subplot(plot_number)
        column = simulink_network_qloss.columns[edge]
        line3, = axs[edge].plot(x, cea_network_qloss[time_start:time_end][column], label='cea')
        line4, = axs[edge].plot(x, simulink_network_qloss[time_start:time_end][column], label='simulink')
        #axs[edge].legend(loc='lower right')
        axs[edge].set_title(column)
        axs[edge].legend(loc='lower right')
        axs[edge].set_ylabel('[kWh]')

figs_qloss.savefig('%s_qloss' %network)

axs_1 = {}
figs_qloss_1 = plt.figure(figsize=(30,20))
figs_qloss_1.subplots_adjust(hspace=1)
for edge in range(simulink_network_qloss.shape[1]):
        plot_number = 811 + edge
        axs_1[edge]=figs_qloss_1.add_subplot(plot_number)
        column = simulink_network_qloss.columns[edge]
        line5, = axs_1[edge].plot(x, percent_d_qloss[time_start:time_end][column])
        #axs[edge].legend(loc='lower right')
        axs_1[edge].set_title(column)
        axs_1[edge].set_ylim((0,100))
        axs_1[edge].set_ylabel('[%]')

figs_qloss_1.savefig('%s_qloss_comparison' %network)

# axs_2 = {}
# figs_qloss_2 = plt.figure(figsize=(30,20))
# figs_qloss_2.subplots_adjust(hspace=1)
# for edge in range(simulink_network_qloss.shape[1]):
#         plot_number = 811 + edge
#         axs_2[edge]=figs_qloss_2.add_subplot(plot_number)
#         column = simulink_network_qloss.columns[edge]
#         line6, = axs_2[edge].plot(x, percent_Phi_loss[time_start:time_end][column])
#         #axs[edge].legend(loc='lower right')
#         axs_2[edge].set_title(column)
#
# figs_qloss_2.savefig('%s_qloss_percentage' %network)



plt.show()
print percent_d_ploss.describe()
print percent_d_qloss.describe()