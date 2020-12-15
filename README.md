# IoT Positioning Exp

学校物联网定位实验
[top]
## 实验一
为硬件设备测试，较为简单，先跳过
## 实验二
### 任务目标
设计和实现一个基于WIFI的无线室内定位系统
### 实验要求
1. 设计和实现一个基于指纹的无线定位系统，包括信号强度收集模块，位置计算模块，并在选定的室内环境下进行测试。
1. 验可以分小组合作完成，每个小组提交一份实验报告，包括系统设计方案，程序源码或伪码，实验结果。
1. 每个小组选派一名同学汇报自己小组的实验过程和结果，准备大概5分钟的ppt
### 已有文件说明
_存在Exp2中_
__这些文件都是用安卓实现的__
1. wifiScannermaster文件为学长A的代码 _因为需要安卓4，所以改名为'wifiScannermaster-android4'_
__但是后来发现生成的包又可以实现扫描，所以勉强可能可以用__
1. wifiPosi文件为学姐A的代码 _因为环境配置问题暂时用不了，所以给名为'wifiPosi-compliedfailed'_
1. BeaconLocation文件为学姐B的代码，但是好像是定位课设的代码，基于蓝牙的定位
1. WifiScan文件为学长B的代码，WifiScan2的好像也是，但是还没跑过
_因为是java文件，所以可能文件名要改_
## 实验三
### 任务目标
在所给的网络中实现所讲授的无线传感器网络定位算法并进行比较
### 实验要求
1. 利用所给的网络数据，实现两种以上的定位算法并进行比较
[迭代式多边定位算法] [DV-HOP算法] [PDM定位算法] [基于MDS的定位算法]
1. 每个小组提交一份实验报告，包括算法原理，算法实现以及实验结果比较
1. 每个小组选派一名同学汇报自己小组的实验过程和结果，准备大概5分钟的ppt
### 已有文件说明
_存在Exp3中_
1. diedai_final.m 为迭代式多边定位算法
1. dvhop_final.m 为DV-HOP算法
1. MDS_final 文件夹为基于MDS的定位算法
_其他的几个.txt文件为测试数据，现在文件的是以前的数据，不确定今年老师有没有换数据_
  -------------------
#### 测试数据格式说明
1. 节点位置数据
文件net1_pos中给出了实验网络中节点的位置数据。每行表示一个节点的位置信息。格式如下
	[节点序号] [节点x坐标] [节点y坐标] [是否锚节点]
    * 示例1
 	1   17.8977  106.2282    1
    表示节点1， 其真实位置为（17.8977,106,2282），该节点是锚节点
    * 示例2
    33   43.4718   95.7603         0
  表示节点33， 其真实位置是(43.4718,95.7603)，该节点是待定位节点。利用某种定位算法计算出来待定位节点的位置后，就可以根据真实位置计算该节点的定位误差。
2. 节点之间的测距信息
* 文件 net1_topo_error_free中给出了网络中相邻节点之间的距离信息。每一行表示两个节点之间的距离。格式如下
	[节点1序号]  [节点2序号] [节点之间距离测量值]
    * 示例1
	1    4    8.3075
	表示节点1和节点4可以相互测量出之间的距离，他们之间的距离是8.3075
* 文件net1_topo_error_5和net1_topo_error_10给出的距离分别是增加了5%和10%误差之后的扰动值。
