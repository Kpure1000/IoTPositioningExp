%~~~~~~~~~~~~~~~~~~~~~~~  DV-Hop�㷨  ~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% BorderLength-----����������ı߳�����λ��m
% NodeAmount-------����ڵ�ĸ���
% BeaconAmount-----�ű�ڵ���
% Sxy--------------���ڴ洢�ڵ����ţ������꣬������ľ���
% Beacon----------�ű�ڵ��������;BeaconAmount*BeaconAmount
% UN-------------δ֪�ڵ��������;2*UNAmount
% Distance------δ֪�ڵ㵽�ű�ڵ�������;2*BeaconAmount
% h---------------�ڵ���ʼ��������
% X---------------�ڵ���������ʼ����,X=[x,y]'
% R------------------�ڵ��ͨ�ž��룬һ��Ϊ10-100m

clear,close all;
BorderLength=200;
NodeAmount=320;%�ڵ�������
BeaconAmount=32;%ê�ڵ�����
UNAmount=NodeAmount-BeaconAmount;
R=50;
Dall=zeros(NodeAmount,NodeAmount);%δ֪�ڵ㵽�ű�ڵ�����ʼ����BeaconAmount��NodeAmount��
h=zeros(NodeAmount,NodeAmount);%��ʼ����Ϊ0��BeaconAmount��NodeAmount��
X=zeros(2,UNAmount);%�ڵ���������ʼ����
Data_post=load('net1_pos.txt');
%*********���Ը�����ͬ�ĵ����ļ�*************
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
    disp('ê�ڵ�����3��,�㷨�޷�ִ��');
    return;
end
BeaconAmount=tempcount;
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
Dall=dis;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~�������������ڲ������ȷֲ����������~~~~~~~~~~~~~~~~~~~~
% C=BorderLength.*rand(2,NodeAmount);
% %���߼��ŵĽڵ�����
% Sxy=[[1:NodeAmount];C];
Sxy=Data_post;
Sxys=Sxy';
%Beacon=[Sxy(2,1:BeaconAmount);Sxy(3,1:BeaconAmount)];%ê�ڵ�����
Beacon=([Sxy(1:BeaconAmount,2),Sxy(1:BeaconAmount,3)])';
%UN=[Sxy(2,(BeaconAmount+1):NodeAmount);Sxy(3,(BeaconAmount+1):NodeAmount)];%δ֪�ڵ�����
UN=([Sxy(BeaconAmount+1:NodeAmount,2),Sxy(BeaconAmount+1:NodeAmount,3)])';
%�����ڵ�ֲ�ͼ
plot(Sxy(1:BeaconAmount,2),Sxy(1:BeaconAmount,3),'r*',Sxy(BeaconAmount+1:NodeAmount,2),Sxy(BeaconAmount+1:NodeAmount,3),'k.')
xlim([0,BorderLength]);
title('* ��ɫê�ڵ� . ��ɫδ֪�ڵ�')
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~��ʼ���ڵ����롢��������~~~~~~~~~~~~~~~~~~~~~~
for i=1:NodeAmount
    for j=1:NodeAmount
        Dall(i,j)=((Sxys(2,i)-Sxys(2,j))^2+(Sxys(3,i)-Sxys(3,j))^2)^0.5;%���нڵ���໥����
        if (Dall(i,j)<=R)&&(Dall(i,j)>0)
            h(i,j)=1;%��ʼ��������
        elseif i==j
            h(i,j)=0;
        else h(i,j)=inf;
        end
    end
end
%~~~~~~~~~~~~~~~~~~~~~~~~~���·���㷨����ڵ������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
%~~~~~~~~~~~~~~~~~~~~~~~~~��ÿ���ű�ڵ��У��ֵ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
h1=h(1:BeaconAmount,1:BeaconAmount); 
D1=Dall(1:BeaconAmount,1:BeaconAmount);
for i=1:BeaconAmount
    dhop(i,1)=sum(D1(i,:))/sum(h1(i,:));%ÿ���ű�ڵ��ƽ��ÿ������
end
D2=Dall((BeaconAmount+1):NodeAmount,1:BeaconAmount);%BeaconAmount��UNAmount��
for i=1:UNAmount
    for j=1:BeaconAmount
        if min(D2(i,:))==D2(i,j)
            DHop(1,i)=D2(i,j);
            Dhop(1,i)=dhop(j,1);%δ֪�ڵ��������ű���У��ֵ
        end
    end
end
hop1=h(1:BeaconAmount,(BeaconAmount+1):NodeAmount);%δ֪�ڵ㵽�ű�������BeaconAmount��UNAmount��
for i=1:UNAmount
    hop=Dhop(1,i);%hopΪ������ű��õ�У��ֵ
    Distance(:,i)=hop*hop1(:,i);%%Beacon��UN�У�
end
%
% %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~��С���˷���δ֪������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
 title('ÿ��δ֪�ڵ�����')
 error=sum(error)/UNAmount