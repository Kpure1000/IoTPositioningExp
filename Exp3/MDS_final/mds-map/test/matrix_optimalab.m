function   [a1,segmaX]=matrix_optimalab(a,b,Dab,Wab)
%%%矩阵重复优化的核心计算程序，a是N个未知节点坐标矩阵，b是M个信标节点坐标矩阵，Dab是未知节点和信标节点之间的测
%%%距矩阵，Wab是未知节点和信标节点之间测距的权重函数；a1是根据重复优化公式计算出来的下一个迭代的未知节点坐标
%%%矩阵，segmaX是当前未知节点坐标矩阵a作为定位坐标矩阵和实际的测距的总的平方误差和，也即优化函数的值
%%%   此函数仅根据未知节点和已知节点之间的测距来进行重复优化计算
%%% a(N*K) is the coordinates of the unknown nodes,N:is the number of the
%%% unknown nodes,K: is the dimensional(2 or 3 in fact)
%%% b(M*K) is the coordinates of the beacon nodes,M: is the number of the
%%% beacon nodes
%%% Dab(N*M) is the measured distance matrix between the unknown node and the
%%% beacon node
%%% Wab(N*M) is the weight matrix between the unknown node and the beacon node
%%% a1(N*K) is the returned coordinate matrix according to the input a
%%% segmaX is the error value according to the measured distance Da and the
%%% estimated coordinates
%%% Author: Xie Dongfeng
row_a=size(a,1);   %%% row_a=N
row_b=size(b,1);   %%% row_b=M
 calculated_disab=L2_distance(a',b');
 %%% calculated_disab is the distance between the unknown nodes and beacon
 %%% nodes by calculating  the estimated coordinates
 B2X=zeros(row_a,row_a);
 B3X=zeros(row_a,row_b);
 B4X=zeros(row_b,row_b);
 lamata=zeros(row_a,row_b);
 for i=1:row_a
     for j=1:row_b
         if(calculated_disab(i,j)~=0)
             lamata(i,j)=Wab(i,j)*Dab(i,j)/calculated_disab(i,j);
         end
     end
 end
 for i=1:row_a
     for j=1:row_b
         B2X(i,i)=B2X(i,i)+lamata(i,j);
     end
 end
 B3X=lamata;
for i=1:row_b
     for j=1:row_a
         B4X(i,i)=B4X(i,i)+lamata(j,i);
     end
end
 sita=-2*(trace(a'*B2X*a)-2*trace(a'*B3X*b)+trace(b'*B4X*b));
 
 V2=zeros(row_a,row_a);
 V3=zeros(row_a,row_b);
 V4=zeros(row_b,row_b);
 for i=1:row_a
     for j=1:row_b
         V2(i,i)=V2(i,i)+Wab(i,j);
     end
 end
 V3=Wab;
 for i=1:row_b
     for j=1:row_a
         V4(i,i)=V4(i,i)+Wab(j,i);
     end
 end
 elta=trace(a'*V2*a)-2*trace(a'*V3*b)+trace(b'*V4*b);

  segma=0;
 for i=1:row_a
     for j=1:row_b
         segma=segma+Wab(i,j)*Dab(i,j)*Dab(i,j);
     end
 end
 segmaX=segma+elta+sita;
 a1=inv(V2)*(B2X*a+(V3-B3X)*b);      
