#!/user/bin/env python
#-*- coding:utf-8 -*-
#Version:3.6.1
#Tool: Pycharm 2017
#Author:Cheng Xin

'''
time    :
program :
function:
'''



import numpy as np
from numpy.linalg import *
import matplotlib.pyplot as plt
path = './data/'
file = ['net1_pos.txt','net1_topo-error free.txt','net1_topo-error 5.txt','net1_topo-error 10.txt']

def get_data_pos(path):
    data_pos = np.loadtxt(path + 'net1_pos.txt',dtype=np.float)
    data_dist = np.loadtxt(path + 'net1_topo-error free.txt', dtype=np.float)
    data_dist5 = np.loadtxt(path + 'net1_topo-error 5.txt', dtype=np.float)
    data_dist10 = np.loadtxt(path + 'net1_topo-error 10.txt', dtype=np.float)

    data_pos[:, 0] -= 1
    data_dist[:, :2] -= 1
    data_dist5[:, :2] -= 1
    data_dist10[:, :2] -= 1

    return data_pos, data_dist, data_dist5, data_dist10


def check_anchor_num(data_pos):
    num_anchor = 0
    for data in data_pos:
        if data[-1] == 1:
            num_anchor += 1
    if num_anchor < 3:
        print('锚节点小于三个无法定位')
    else:
        print('锚节点数目 ：  {}'.format(num_anchor))
    return num_anchor

def floyd(shortest_path, num):
    for i in range(num):
        for j in range(num):
            for k in range(num):
                shortest_path[j,k] = min(shortest_path[j,k], shortest_path[i,j] + shortest_path[j,k])

def gen_path(data_dist, ):
    path = []