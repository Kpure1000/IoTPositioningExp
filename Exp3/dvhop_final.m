%~~~~~~~~~~~~~~~~~~~~~~~  DV-Hop算法  ~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% BorderLength-----正方形区域的边长，单位：m
% NodeAmount-------网络节点的个数
% BeaconAmount-----信标节点数
% Sxy--------------用于存储节点的序号，横坐标，纵坐标的矩阵
% Beacon----------信标节点坐标矩阵;BeaconAmount*BeaconAmount
% UN-------------未知节点坐标矩阵;2*UNAmount
% Distance------未知节点到信标节点距离矩阵;2*BeaconAmount
% h---------------节点间初始跳数矩阵
% X---------------节点估计坐标初始矩阵,X=[x,y]'
% R------------------节点的通信距离，一般为10-100m

clear,close all;
BorderLength=200;
NodeAmount=320;%节点总数量
BeaconAmount=32;%锚节点数量
UNAmount=NodeAmount-BeaconAmount;
R=50;
Dall=zeros(NodeAmount,NodeAmount);%未知节点到信标节点距离初始矩阵；BeaconAmount行NodeAmount列
h=zeros(NodeAmount,NodeAmount);%初始跳数为0；BeaconAmount行NodeAmount列
X=zeros(2,UNAmount);%节点估计坐标初始矩阵
Data_post=load('net1_pos.txt');
%*********可以更换不同的导入文件*************
Data_post1=load('net1_topo-error free.txt');
%Data_post1=load('net1_topo-error 5.txt');
%Data_post1=load('net1_topo-error 10.txt');
NodeAmount=size(Data_post);
culunm_post=NodeAmount;
dis_n = size(Data_post1);
tempcount = 0;
for i=1:culunm_post(1)
    if (Data_post(i,4)==1)
        tempcount=tempcount+1;
    end
end
if tempcount < 3
    disp('锚节点少于3个,算法无法执行');
    return;
end
BeaconAmount=tempcount;
%初始化距离矩阵,自身赋值为0，其他赋值为无穷大
dis = zeros(culunm_post(1),culunm_post(1));
for i=1:culunm_post(1)
    for j=1:culunm_post(1)
        dis(i,j) = inf;
        if(i == j)
            dis(i,j) = 0;
        end
    end
end
%与锚节点有关的路径读入距离矩阵
for i = 1:dis_n(1)
    if(Data_post1(i,1) <= tempcount)%如果是锚节点
        dis(Data_post1(i,1),Data_post1(i,2))=Data_post1(i,3);
    elseif(Data_post1(i,2) <= tempcount)
        dis(Data_post1(i,2),Data_post1(i,1))=Data_post1(i,3);
        %end
    end
end
Dall=dis;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~在正方形区域内产生均匀分布的随机拓扑~~~~~~~~~~~~~~~~~~~~
% C=BorderLength.*rand(2,NodeAmount);
% %带逻辑号的节点坐标
% Sxy=[[1:NodeAmount];C];
Sxy=Data_post;
Sxys=Sxy';
%Beacon=[Sxy(2,1:BeaconAmount);Sxy(3,1:BeaconAmount)];%锚节点坐标
Beacon=([Sxy(1:BeaconAmount,2),Sxy(1:BeaconAmount,3)])';
%UN=[Sxy(2,(BeaconAmount+1):NodeAmount);Sxy(3,(BeaconAmount+1):NodeAmount)];%未知节点坐标
UN=([Sxy(BeaconAmount+1:NodeAmount,2),Sxy(BeaconAmount+1:NodeAmount,3)])';
%画出节点分布图
plot(Sxy(1:BeaconAmount,2),Sxy(1:BeaconAmount,3),'r*',Sxy(BeaconAmount+1:NodeAmount,2),Sxy(BeaconAmount+1:NodeAmount,3),'k.')
xlim([0,BorderLength]);
title('* 红色锚节点 . 黑色未知节点')
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~初始化节点间距离、跳数矩阵~~~~~~~~~~~~~~~~~~~~~~
for i=1:NodeAmount
    for j=1:NodeAmount
        Dall(i,j)=((Sxys(2,i)-Sxys(2,j))^2+(Sxys(3,i)-Sxys(3,j))^2)^0.5;%所有节点间相互距离
        if (Dall(i,j)<=R)&&(Dall(i,j)>0)
            h(i,j)=1;%初始跳数矩阵
        elseif i==j
            h(i,j)=0;
        else h(i,j)=inf;
        end
    end
end
%~~~~~~~~~~~~~~~~~~~~~~~~~最短路经算法计算节点间跳数~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
for k=1:NodeAmount
    for i=1:NodeAmount
        for j=1:NodeAmount
            if h(i,k)+h(k,j)<h(i,j)%min(h(i,j),h(i,k)+h(k,j))
                h(i,j)=h(i,k)+h(k,j);
            end
        end
    end
end
% h
%~~~~~~~~~~~~~~~~~~~~~~~~~求每个信标节点的校正值~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
h1=h(1:BeaconAmount,1:BeaconAmount); 
D1=Dall(1:BeaconAmount,1:BeaconAmount);
for i=1:BeaconAmount
    dhop(i,1)=sum(D1(i,:))/sum(h1(i,:));%每个信标节点的平均每跳距离
end
D2=Dall((BeaconAmount+1):NodeAmount,1:BeaconAmount);%BeaconAmount行UNAmount列
for i=1:UNAmount
    for j=1:BeaconAmount
        if min(D2(i,:))==D2(i,j)
            DHop(1,i)=D2(i,j);
            Dhop(1,i)=dhop(j,1);%未知节点从最近的信标获得校正值
        end
    end
end
hop1=h(1:BeaconAmount,(BeaconAmount+1):NodeAmount);%未知节点到信标跳数，BeaconAmount行UNAmount列
for i=1:UNAmount
    hop=Dhop(1,i);%hop为从最近信标获得的校正值
    Distance(:,i)=hop*hop1(:,i);%%Beacon行UN列；
end
%
% %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~最小二乘法求未知点坐标~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
d=Distance;
for i=1:2
    for j=1:(BeaconAmount-1)
      a(i,j)=Beacon(i,j)-Beacon(i,BeaconAmount);
    end
end
A=-2*(a');
% d=d1';
 for m=1:UNAmount 
     for i=1:(BeaconAmount-1)
         B(i,1)=d(i,m)^2-d(BeaconAmount,m)^2-Beacon(1,i)^2+Beacon(1,BeaconAmount)^2-Beacon(2,i)^2+Beacon(2,BeaconAmount)^2;
     end
           X1=inv(A'*A)*A'*B;
           X(1,m)=X1(1,1);
           X(2,m)=X1(2,1);
 end
 for i=1:UNAmount
      error(1,i)=(((X(1,i)-UN(1,i))^2+(X(2,i)-UN(2,i))^2)^0.5);
 end
 hold on; plot(X(1,:),X(2,:),'o')
 figure;plot(error,'-o')
 title('每个未知节点的误差')
 error=sum(error)/UNAmount