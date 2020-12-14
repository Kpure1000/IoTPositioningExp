clear all;close all;
global N M   %N：未知节点数目，M：信标节点数目
Data_post=load('net1_pos.txt');
%*********可以更换不同的导入文件*************
Data_post1=load('net1_topo-error free.txt');
%Data_post1=load('net1_topo-error 5.txt');
%Data_post1=load('net1_topo-error 10.txt');
culunm_post=size(Data_post);
dis_n = size(Data_post1);
NodeAmount=culunm_post(1);
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
N=culunm_post(1)-tempcount;M=tempcount;
BeaconAmount=M;
Sxy=Data_post;
radius=50;
%%actualunknownnodecoor=10*rand(N,2);
actualunknownnodecoor=[Sxy(BeaconAmount+1:NodeAmount,2),Sxy(BeaconAmount+1:NodeAmount,3)];
%%refnodecoor=10*rand(M,2);
refnodecoor=[Sxy(1:BeaconAmount,2),Sxy(1:BeaconAmount,3)];
undis=L2_distance(actualunknownnodecoor',actualunknownnodecoor');
refdis=L2_distance(actualunknownnodecoor',refnodecoor');
CN=zeros(N);
CNM=zeros(N,M);
for i=1:N
    for j=1:N
        if(i~=j&&undis(i,j)<=radius)
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

iterative_time=60;
absolute_error_value=0.0001;
%initial_value=10*randn(N,2);
initial_value=zeros(N,2); 
a0 = initial_value;
e = calcuEmax(a0,refnodecoor,undis,refdis,CN,CNM);
for i = 0:10
    e = e-e/10*i;
    k = 0;
    [a1,segmaX0] = DistanceSmoothOptimal(a0,refnodecoor,undis,refdis,CN,CNM,e);
    segmaX1 = segmaX0;
    while(k==0|(segmaX0-segmaX1>absolute_error_value&&k<=iterative_time))
          k = k+1;
          segmaX0 = segmaX1;
          a0 = a1;
          [a1,segmaX1] = DistanceSmoothOptimal(a0,refnodecoor,undis,refdis,CN,CNM,e);
    end
end
calcoor = a1;
axis auto;
grid on;
hold on;
plot(actualunknownnodecoor(:,1),actualunknownnodecoor(:,2),'r*');
plot(refnodecoor(:,1),refnodecoor(:,2),'ko');
plot(calcoor(:,1),calcoor(:,2),'bd');