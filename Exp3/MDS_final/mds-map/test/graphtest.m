global N M    %%N是未知节点数目，M是已知节点数目
N=320;M=4;
radius=5;     %%设通信半径为5m
actualunknownnodecoor=8*rand(N,2)+ones(N,2);     %%未知节点实际坐标分布在8*8的区域内
%%actualunknownnodecoor=10*rand(N,2);
%%refnodecoor=10*rand(M,2);
refnodecoor=[0 0;10 0;10 10;0 10];        %%参考（信标）节点分布在四个边角
undis=L2_distance(actualunknownnodecoor',actualunknownnodecoor');    %%计算未知节点两两之间的欧拉距离
refdis=L2_distance(actualunknownnodecoor',refnodecoor');             %%计算未知节点和 信标节点之间的欧拉距离；L2_distance调用函数，计算两个坐标矩阵所代表的点阵之间欧拉距离
CN=zeros(N);         %%未知节点之间的互联关系初始化，也即权重函数
CNM=zeros(N,M);      %%未知节点与信标节点之间的互联关系初始化，也即权重函数
for i=1:N
    for j=1:N
        if(i~=j&&undis(i,j)<=radius)    %%当节点之间距离在通信半径内，则测距有效，权重函数设为1
            CN(i,j)=1;
        end
    end
end
for i=1:N
    for j=1:M
        if(refdis(i,j)<=radius)
            CNM(i,j)=1;
        end
    end
end

iterative_time=60;              %%迭代次数设为60
absolute_error_value=0.0001;     %%%迭代最小差值
%% initial_value=10*randn(N,2);
initial_value=zeros(N,2);           %%%初始坐标矩阵设为0
a0=initial_value;
[a1,segmaX0]=matrix_optimal(a0,refnodecoor,undis,refdis,CN,CNM);
segmaX1=segmaX0;
k=0;
while(k==0|(segmaX0-segmaX1>absolute_error_value&&k<=iterative_time))
    k=k+1;
    segmaX0=segmaX1;
    a0=a1;
    [a1,segmaX1]=matrix_optimal(a0,refnodecoor,undis,refdis,CN,CNM);    %%%矩阵迭代优化，返回下一个坐标a1和当前最小值segmaX1
end
calcoor=a1;
rectangle('Position',[0,0,10,10]);       %%%下面这些是画图程序
axis auto;
grid on;
hold on;
plot(actualunknownnodecoor(:,1),actualunknownnodecoor(:,2),'r*');   %%%未知节点实际坐标用红色*号表示
plot(refnodecoor(:,1),refnodecoor(:,2),'ko');                      %%%参考节点用黑色圆圈表示
plot(calcoor(:,1),calcoor(:,2),'bd');                     %%%定位坐标用钻石符号表示
