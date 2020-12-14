function   [a1,segmaX]=matrix_optimala(a,Da,Wa)
%%%矩阵重复优化的核心计算程序之一，a是N个未知节点坐标矩阵，Da是未知节点之间的测距矩阵，Wa是未知节点之间测距的权重函数，
%%%% a1是根据重复优化公式计算出来的下一个迭代的未知节点坐标
%%%矩阵，segmaX是当前未知节点坐标矩阵a作为定位坐标矩阵和实际的测距的总的平方误差和，也即优化函数的值，此函数只利用未知节点坐标矩阵之间的测距
%%%信息，计算出来的有可能是相对坐标
%%% a(N*K) is the coordinates of the unknown nodes,N:is the number of the
%%% unknown nodes,K: is the dimensional(2 or 3 in fact)
%%% Da(N*N) is the measured distance matrix between the unknown nodes
%%% Wa(N*N) is the weight matrix of the unknown nodes
%%% a1(N*K) is the returned coordinate matrix according to the input a
%%% segmaX is the error value according to the measured distance Da and the
%%% estimated coordinates
%%% Author: Xie Dongfeng
row_a=size(a,1);
%%% row_a=N
 calculated_disa=L2_distance(a',a');
 %%% calculated_disa is the distance between the unknown nodes by
 %%% calculating  the estimated coordinates
 
 B1X=zeros(row_a,row_a);
 for i=1:row_a
     for j=1:row_a
         if(i~=j&&calculated_disa(i,j)~=0)
             B1X(i,j)=-Wa(i,j)*Da(i,j)/calculated_disa(i,j);
         end
     end
 end
 for i=1:row_a
     for j=1:row_a
         if(j~=i)
             B1X(i,i)=B1X(i,i)-B1X(i,j);
         end
     end
 end
 
 V1=zeros(row_a,row_a);
 for i=1:row_a
     for j=1:row_a
         if(i~=j)
             V1(i,j)=-Wa(i,j);
             V1(i,i)=V1(i,i)+Wa(i,j);
         end
     end
 end
 V1a=inv(V1+ones(row_a))-1/(row_a^2)*ones(row_a);
 a1=V1a*B1X*a;
 
 segma=0;
 for i=1:row_a
     for j=i+1:row_a
         segma=segma+Wa(i,j)*Da(i,j)*Da(i,j);
     end
 end
 segmaX=segma+trace(a'*V1*a)-2*trace(a'*B1X*a);
        