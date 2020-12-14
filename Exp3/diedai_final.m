Data_post=load('net1_pos.txt');
%*********可以更换不同的导入文件*************
%Data_post1=load('net1_topo-error free.txt');
Data_post1=load('net1_topo-error 5.txt');
%Data_post1=load('net1_topo-error 10.txt');
culunm_post=size(Data_post);
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
%初始化estimated
estimated = zeros(culunm_post(1),2);
for i = 1:tempcount
    estimated(i,1)=Data_post(i,2);
    estimated(i,2)=Data_post(i,3);
end
canRun=1;
tempcount2=0;
while(canRun)
for j=1:culunm_post(1)%循环不是锚节点
    if(Data_post(j,4)==0)
    count=0;
    temp=zeros(3,3);
    for i=1:culunm_post(1)
        if(Data_post(i,4)==1&&dis(i,j)~=inf)
        %if(dis(i,j)~=inf)
            count=count+1;
            temp(count,:)=[Data_post(i,2) Data_post(i,3) dis(i,j)];
            %存放有关锚节点x,y,d
        end
    end
    if(count>=3)%找到有三个有关的锚节点
        %计算位置
        point = temp(1,3)^2-temp(1,1)^2-temp(1,2)^2;
        A = zeros(count-1,2);
        b = zeros(count-1,1);
        for ii=2:count%-1
           A(ii-1,:)=2*[temp(1,1)-temp(ii,1) temp(1,2)-temp(ii,2)];
           b(ii-1,:)=temp(ii,3)^2-temp(ii,1)^2-temp(ii,2)^2-point;
        end
        Ans = (transpose(A)*A)\transpose(A)*b;
        estimated(j,1) = Ans(1,1);
        estimated(j,2) = Ans(2,1);
        %画出实际的点和计算出的点的连线
        plot([Data_post(j,2),estimated(j,1)],[Data_post(j,3),estimated(j,2)]);
        %添加该点为锚节点
        hold on;
        tempcount=tempcount+1;
        for m = 1:dis_n(1)
            if (Data_post1(m,1)==j)
                dis(Data_post1(m,1),Data_post1(m,2)) = Data_post1(m,3);
            elseif (Data_post1(m,2)==j)
                dis(Data_post1(m,2) ,Data_post1(m,1)) = Data_post1(m,3);
            end
        end
        Data_post(j,4)=1;
        %break;
    end
    end
end
%如果计算出全部结点或者两次循环的锚节点个数不再增长，退出循环
if(tempcount==culunm_post(1)||tempcount2==tempcount)
    canRun=0;
end
tempcount2=tempcount;
end
%用“O”画出经过运算后的点
scatter(estimated(:,1),estimated(:,2),'k');
hold on;
%用“.”画出实际的点
scatter(Data_post(:,2),Data_post(:,3),'b','.');
hold on;