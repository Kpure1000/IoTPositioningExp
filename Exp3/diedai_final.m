Data_post=load('net1_pos.txt');
%*********���Ը�����ͬ�ĵ����ļ�*************
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
    disp('ê�ڵ�����3��,�㷨�޷�ִ��');
    return;
end
%��ʼ���������,����ֵΪ0��������ֵΪ�����
dis = zeros(culunm_post(1),culunm_post(1));
for i=1:culunm_post(1)
    for j=1:culunm_post(1)
        dis(i,j) = inf;
        if(i == j)
            dis(i,j) = 0;
        end
    end
end
%��ê�ڵ��йص�·������������
for i = 1:dis_n(1)
    if(Data_post1(i,1) <= tempcount)%�����ê�ڵ�
        dis(Data_post1(i,1),Data_post1(i,2))=Data_post1(i,3);
    elseif(Data_post1(i,2) <= tempcount)
        dis(Data_post1(i,2),Data_post1(i,1))=Data_post1(i,3);
        %end
    end
end
%��ʼ��estimated
estimated = zeros(culunm_post(1),2);
for i = 1:tempcount
    estimated(i,1)=Data_post(i,2);
    estimated(i,2)=Data_post(i,3);
end
canRun=1;
tempcount2=0;
while(canRun)
for j=1:culunm_post(1)%ѭ������ê�ڵ�
    if(Data_post(j,4)==0)
    count=0;
    temp=zeros(3,3);
    for i=1:culunm_post(1)
        if(Data_post(i,4)==1&&dis(i,j)~=inf)
        %if(dis(i,j)~=inf)
            count=count+1;
            temp(count,:)=[Data_post(i,2) Data_post(i,3) dis(i,j)];
            %����й�ê�ڵ�x,y,d
        end
    end
    if(count>=3)%�ҵ��������йص�ê�ڵ�
        %����λ��
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
        %����ʵ�ʵĵ�ͼ�����ĵ������
        plot([Data_post(j,2),estimated(j,1)],[Data_post(j,3),estimated(j,2)]);
        %��Ӹõ�Ϊê�ڵ�
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
%��������ȫ������������ѭ����ê�ڵ���������������˳�ѭ��
if(tempcount==culunm_post(1)||tempcount2==tempcount)
    canRun=0;
end
tempcount2=tempcount;
end
%�á�O���������������ĵ�
scatter(estimated(:,1),estimated(:,2),'k');
hold on;
%�á�.������ʵ�ʵĵ�
scatter(Data_post(:,2),Data_post(:,3),'b','.');
hold on;