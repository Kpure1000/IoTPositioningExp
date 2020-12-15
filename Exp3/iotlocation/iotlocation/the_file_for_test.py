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

a = np.full((2,3),float('inf'),float)
print(a)
print(a.T)
a = np.arange(12).reshape(3,4)
print(a**2)
print(a[1:,0]**2)


a = np.arange(10).reshape((2,5))
b = np.arange(10).reshape((5,2))
print(np.dot(a,b))