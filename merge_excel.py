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

path_to_matlab = os.path.abspath(r'C:\Users\fcl2\Documents\MATLAB\network\network2_DH_parts')
# path_to_matlab = os.path.abspath(r'C:\Users\Shanshan\Documents\GitHub\network\network3_DH')
# simulink_network_qloss = pd.read_csv(os.path.join(path_to_matlab,'%s_qloss_supply.csv' %network))

parts = [1, 3001, 5001, 6001, 7001, 8001, 8201, 8401, 8601]
# part_1 = 1
# part_2 = 3001
# part_3 = 5001
# part_4 = 6001
# part_5 = 7001
# part_6 = 8001
# part_7 = 8201
# part_8 = 8401

qloss_total = pd.DataFrame(np.zeros(shape=(8760,8)))
dP_total = pd.DataFrame(np.zeros(8760))


for i in range(len(parts)-1):
    name_to_parts = '%s' %parts[i] + '-' + '%s' %(parts[i+1]-1)
    path_to_parts = os.path.join(path_to_matlab, name_to_parts)
    qloss = pd.read_csv(os.path.join(path_to_parts,'%s_Phi_W_supply.csv' %network))
    dP = pd.read_csv(os.path.join(path_to_parts, '%s_dP_supply.csv' %network), header= None)
    qloss_total[parts[i]-1:parts[i+1]-2] = qloss[parts[i]-1:parts[i+1]-2]
    dP_total[parts[i] - 1:parts[i + 1] - 2] = dP[parts[i] - 1:parts[i + 1] - 2]

qloss_total.columns = qloss.columns.values.tolist()
qloss_total.to_csv(os.path.join(path_to_matlab, '%s_Phi_W_supply.csv' %network), na_rep='0', index=False, float_format='%.3f')
dP_total.to_csv(os.path.join(path_to_matlab, '%s_dP_supply.csv' %network), na_rep='0', index=False, float_format='%.3f')
print qloss.columns