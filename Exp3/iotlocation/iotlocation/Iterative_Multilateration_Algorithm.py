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


def gen_dist_mat(data_dist, anchor_index, node_index):
    num_nodes = len(node_index)
    dist_mat = np.full((num_nodes, num_nodes), float('inf'), float)
    for i in range(num_nodes):
        x = int(data_dist[i,0])
        y = int(data_dist[i,1])
        if x in anchor_index or y in anchor_index:
            dist_mat[x, y] = data_dist[i,2]
            dist_mat[y, x] = data_dist[i,2]
    return dist_mat

def gen_pos_mat(data_pos, num_anchor, num_nodes):
    pos_mat = np.zeros((num_nodes, 2), dtype=np.float)
    for i in range(num_anchor):
        pos_mat[i,:] = data_pos[i,1:3]
    return pos_mat

def cal_pos(dist_mat, pos_mat, anchor_index, node_index):
    for i in node_index - anchor_index:
        dist_arr = dist_mat[i][dist_mat[i] < float('inf')]

        num = len(dist_arr)
        if num >= 3:
            dist_arr = dist_arr.reshape(-1, 1)
            index_arr = np.argsort(dist_mat[i])[:num]
            associated_nodes_pos = pos_mat[index_arr]

            A = 2*(associated_nodes_pos[0] - associated_nodes_pos[1:])
            b = np.square(dist_arr[1:]).reshape(-1,1) - np.square(associated_nodes_pos[1:,0]).reshape(-1,1)  - np.square(associated_nodes_pos[1:,1]).reshape(-1,1)  -\
                (np.square(dist_arr[0]) - np.square(associated_nodes_pos[0,0]) - np.square(associated_nodes_pos[0,1]))
            x =np.dot(np.dot( inv(np.dot(A.T, A)), A.T),b)

            pos_mat[i] = x.T
            anchor_index.add(i)
    return pos_mat, anchor_index

def cal_all_pos(data_dist, dist_mat, pos_mat, anchor_index, node_index):
    time = 0
    # 循环
    while(1):
        num_anchor = len(anchor_index)

        pos_mat, anchor_index = cal_pos(dist_mat, pos_mat, anchor_index, node_index)  #更新pos，anchor——index
        dist_mat = gen_dist_mat(data_dist, anchor_index, node_index)    #更新dest_nat

        if num_anchor ==  len(anchor_index):
            time += 1
            print(time)
            if time > 5:
                break

    return pos_mat, anchor_index

def draw(pos_mat, pos_mat_new):
    fig = plt.figure()
    plt.scatter(pos_mat[:,0].T, pos_mat[:,1].T, c='r',marker='.')
    plt.scatter(pos_mat_new[:,0].T, pos_mat_new[:,1].T, c='b', marker='*')

    plt.show()

def main():

    data_pos, data_dist, data_dist5, data_dist10 = get_data_pos(path)
    num_anchor = check_anchor_num(data_pos)
    num_nodes = data_pos.shape[0]
    #----------------------------------------------
    node_index = set(list(range(num_nodes)))
    anchor_index = set(list(range(num_anchor)))
    #------------------------------------------------
    dist_mat = gen_dist_mat(data_dist, anchor_index, node_index)
    pos_mat = gen_pos_mat(data_pos, num_anchor, num_nodes)

    pos_mat_new, anchor_index = cal_all_pos(data_dist, dist_mat, pos_mat, anchor_index, node_index)
    print(len(pos_mat_new[pos_mat_new > 0]))

    draw(data_pos, pos_mat_new)


if __name__ == '__main__':
    main()
