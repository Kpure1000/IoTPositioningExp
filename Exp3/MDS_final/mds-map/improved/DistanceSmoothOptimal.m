function   [a1,segma] = DistanceSmootOptimal(a,b,Da,Dab,Wa,Wab,e)
%%%% 距离平滑后的程序，仅仅是将Da，Dab 距离运用平滑函数重新计算了一下
%%% a(N*K) is the coordinates of the unknown nodes,N:is the number of the
%%% unknown nodes,K: is the dimensional(2 or 3 in fact)
%%% b(M*K) is the coordinates of the beacon nodes,M: is the number of the
%%% beacon nodes
%%% Da(N*N) is the measured distance matrix between the unknown nodes
%%% Wa(N*N) is the weight matrix of the unknown nodes
%%% Dab(N*M) is the measured distance matrix between the unknown node and the
%%% beacon node
%%% Wab(N*M) is the weight matrix between the unknown node and the beacon node
%%% a1(N*K) is the returned coordinate matrix according to the input a
%%% segma is the error value according to the measured distance Da and the
%%% estimated coordinates
%%% Author: Xie Dongfeng

[row_a,column_a]=size(a);
row_b=size(b,1);
calculated_disab=L2_distance(a',b');
calculated_disa=L2_distance(a',a');
 %%% calculated_disab is the distance between the unknown nodes  and beacon 
 %%% nodes by calculating  the estimated coordinates
 %%% calculated_disa is the distance between the unknown nodes  by
 %%% calculating
 V1=zeros(row_a,row_a);
 V2=zeros(row_a,row_a);
 V3=zeros(row_a,row_b);
 V4=zeros(row_b,row_b);
 for i=1:row_a
     for j=1:row_a
         if(i~=j)
             V1(i,j)=-Wa(i,j);
             V1(i,i)=V1(i,i)+Wa(i,j);
         end
     end
 end
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
 
 revisedDisa=zeros(row_a,row_a);
for i=1:row_a
    for j=1:row_a
        for k=1:column_a
            revisedDisa(i,j)=revisedDisa(i,j)+DistanceSmooth(a(i,k)-a(j,k),e)^2;
        end
        revisedDisa(i,j) = sqrt(revisedDisa(i,j));
    end
end
revisedDisab=zeros(row_a,row_b);
for i=1:row_a
    for j=1:row_b
        for k=1:column_a
            revisedDisab(i,j)=revisedDisab(i,j)+DistanceSmooth(a(i,k)-b(j,k),e)^2;
        end
         revisedDisab(i,j) = sqrt(revisedDisab(i,j));
    end
end
 
 elta0=0;
 for i=1:row_a
     for j=i+1:row_a
         elta0=elta0+Wa(i,j)*Da(i,j)*Da(i,j);
     end
 end
  
 alfa1=zeros(row_a,row_a,column_a);
 beta1=zeros(row_a,row_a,column_a);
 P1X=zeros(row_a,column_a);
 lamata0 = 0;
 for i=1:row_a
     for j=1:row_a
         for k=1:column_a
             if(abs(a(i,k)-a(j,k))<e)
                 alfa1(i,j,k) = 3.5-(a(i,k)-a(j,k))^2/(2*e*e);
             else
                 alfa1(i,j,k)=3;
             end
         end
     end
 end
 for i=1:row_a
     for j=1:row_a
         for k=1:column_a
             beta1(i,j,k) = DistanceSmooth((a(i,k)-a(j,k)),e)^2 - 4*(a(i,k)-a(j,k))^2+2*(a(i,k)-a(j,k))^2*alfa1(i,j,k);
         end
     end
 end
 for i=1:row_a
     for k=1:column_a
         for j=1:row_a
             if(j~=i)
                  P1X(i,k) = P1X(i,k)+Wa(i,j)*(a(i,k)-a(j,k))*alfa1(i,j,k);
             end
         end
     end
 end
 for i=1:row_a
     for j=i+1:row_a
         TEMP0 = 0;
         for k=1:column_a
              TEMP0 = TEMP0 + beta1(i,j,k);
         end
         lamata0 = lamata0 + Wa(i,j) * TEMP0;
     end
 end
 elta1 = 4*trace(a'*V1*a)-2*trace(a'*P1X)+lamata0;
 
 alfa2=zeros(row_a,row_a,column_a);
 beta2=zeros(row_a,row_a,column_a);
 P2X=zeros(row_a,column_a);
 lamata1 = 0;
 for i=1:row_a
     for j=1:row_a
         for k=1:column_a
             if(abs(a(i,k)-a(j,k))<e)
                 alfa2(i,j,k) = DistanceSmooth((a(i,k)-a(j,k)),e)/e;
             else
                 alfa2(i,j,k)=1;
             end
         end
     end
 end
 for i=1:row_a
     for j=1:row_a
         for k=1:column_a
             if(abs(a(i,k)-a(j,k))<e)
                  beta2(i,j,k) = DistanceSmooth((a(i,k)-a(j,k)),e)*((a(i,k)-a(j,k))^2/e-DistanceSmooth((a(i,k)-a(j,k)),e));
             else
                 beta2(i,j,k)=0;
             end
         end
     end
 end
 for i=1:row_a
     for k=1:column_a
         for j=1:row_a
             if(j~=i)
                  P2X(i,k) = P2X(i,k)+Wa(i,j)*Da(i,j)/revisedDisa(i,j)*(a(i,k)-a(j,k))*alfa2(i,j,k);
             end
         end
     end
 end
 for i=1:row_a
     for j=i+1:row_a
         TEMP1 = 0;
         for k=1:column_a
              TEMP1 = TEMP1 + beta2(i,j,k);
         end
         lamata1 = lamata1 + Wa(i,j) * Da(i,j)/revisedDisa(i,j)*TEMP1;
     end
 end
 elta2 = -2*trace(a'*P2X)+2*lamata1;
 segmaXa = elta0+elta1+elta2;

 elta3=0;
 for i=1:row_a
     for j=1:row_b
         elta3=elta3+Wab(i,j)*Dab(i,j)*Dab(i,j);
     end
 end
 
 alfa3 = zeros(row_a,row_b,column_a);
 beta3 = zeros(row_a,row_b,column_a);
 P3X = zeros(row_a,column_a);
 for i=1:row_a
     for j=1:row_b
         for k=1:column_a
             if(abs(a(i,k)-b(j,k))<e)
                 alfa3(i,j,k) = 3.5-(a(i,k)-b(j,k))^2/(2*e*e);
             else
                 alfa3(i,j,k)=3;
             end
         end
     end
 end
 for i=1:row_a
     for j=1:row_b
         for k=1:column_a
             beta3(i,j,k) = DistanceSmooth((a(i,k)-b(j,k)),e)^2 - 4*(a(i,k)-b(j,k))^2+2*(a(i,k)-b(j,k))^2*alfa3(i,j,k);
         end
     end
 end
 for i=1:row_a
     for k=1:column_a
         for j=1:row_b
              P3X(i,k) = P3X(i,k)+Wab(i,j)*(a(i,k)-b(j,k))*alfa3(i,j,k);
         end
     end
 end
 
 test1=0;
 for i=1:row_a
     for j=1:row_b
         temp11=0;
         for k=1:column_a
             temp11=temp11+(a(i,k)-b(j,k))^2*alfa3(i,j,k);
         end
         test1=test1+temp11*Wab(i,j);
     end
 end
 
 
 lamata2 = trace(a'*V2*a)-2*trace(a'*V3*b)+trace(b'*V4*b);
 lamata3 = 0;
 for i=1:row_a
     for j=1:row_b
         TEMP3 = 0;
         for k=1:column_a
              TEMP3 = TEMP3 + beta3(i,j,k);
         end
         lamata3 = lamata3 + Wab(i,j) * TEMP3;
     end
 end
 %%elta4 = 4*lamata2-2*trace(a'*P3X)+lamata3;
 elta4 = 4*lamata2-2*test1+lamata3;
 
 alfa4 = zeros(row_a,row_b,column_a);
 beta4 = zeros(row_a,row_b,column_a);
 P4X = zeros(row_a,column_a);
 for i=1:row_a
     for j=1:row_b
         for k=1:column_a
             if(abs(a(i,k)-b(j,k))<e)
                 alfa4(i,j,k) = DistanceSmooth((a(i,k)-b(j,k)),e)/e;
             else
                 alfa4(i,j,k)=1;
             end
         end
     end
 end
 for i=1:row_a
     for j=1:row_b
         for k=1:column_a
             if(abs(a(i,k)-b(j,k))<e)
                 beta4(i,j,k) = DistanceSmooth((a(i,k)-b(j,k)),e)*((a(i,k)-b(j,k))^2/e-DistanceSmooth((a(i,k)-b(j,k)),e));
             else
                 beta4(i,j,k) = 0;
             end
         end
     end
 end
 for i=1:row_a
     for k=1:column_a
         for j=1:row_b
                  P4X(i,k) = P4X(i,k)+Wab(i,j)*Dab(i,j)/revisedDisab(i,j)*(a(i,k)-b(j,k))*alfa4(i,j,k);
         end
     end
 end
 
 test2=0;
 for i=1:row_a
     for j=1:row_b
         temp21=0;
         for k=1:column_a
             temp21=temp21+(a(i,k)-b(j,k))^2*alfa4(i,j,k);
         end
         test2=test2+temp21*Wab(i,j)*Dab(i,j)/revisedDisab(i,j);
     end
 end
 
 lamata4 = 0;
 for i=1:row_a
     for j=1:row_b
         TEMP4 = 0;
         for k=1:column_a
              TEMP4 = TEMP4 + beta4(i,j,k);
         end
         lamata4 = lamata4 + Wab(i,j) * Dab(i,j)/revisedDisab(i,j)*TEMP4;
     end
 end
 %%elta5 = -2*trace(a'*P4X)+2*lamata4;
   elta5 = -2*test2+2*lamata4;
 segmaXab = elta3+elta4+elta5;
 segma = segmaXa+segmaXab;
 a1 = inv(V1+V2)*((P1X+P2X+P3X+P4X)/4+V3*b);                