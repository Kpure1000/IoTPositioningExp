function   [a1,segmaX] = DistanceSmoothOptimala(a,Da,Wa,e)
%%% a(N*K) is the coordinates of the unknown nodes,N:is the number of the
%%% unknown nodes,K: is the dimensional(2 or 3 in fact)
%%% Da(N*N) is the measured distance matrix between the unknown nodes
%%% Wa(N*N) is the weight matrix of the unknown nodes
%%% a1(N*K) is the returned coordinate matrix according to the input a
%%% segmaX is the error value according to the measured distance Da and the
%%% estimated coordinates
%%% Author: Xie Dongfeng
[row_a,column_a]=size(a);
%%% row_a=N
revisedDisa=zeros(row_a,row_a);
for i=1:row_a
    for j=1:row_a
        if(j~=i)
             for k=1:column_a
                  revisedDisa(i,j)=revisedDisa(i,j)+DistanceSmooth(a(i,k)-a(j,k),e)^2;
             end
        end
        revisedDisa(i,j) = sqrt(revisedDisa(i,j));
    end
end
 
 elta0=0;
 for i=1:row_a
     for j=i+1:row_a
         elta0=elta0+Wa(i,j)*Da(i,j)*Da(i,j);
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
 
 test3=0;
 for i=1:row_a
     for j=i+1:row_a
         temp31=0;
         for k=1:column_a
             temp31=temp31+(a(i,k)-a(j,k))^2*alfa1(i,j,k);
         end
         test3=test3+temp31*Wa(i,j);
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
 %elta1 = 4*trace(a'*V1*a)-2*trace(a'*P1X)+lamata0;
 elta1 = 4*trace(a'*V1*a)-2*test3+lamata0;
 
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
                 alfa2(i,j,k) = 1;
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
                 beta2(i,j,k) = 0;
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
 
 test4=0;
 for i=1:row_a
     for j=i+1:row_a
         temp41=0;
         for k=1:column_a
             temp41=temp41+(a(i,k)-a(j,k))^2*alfa2(i,j,k);
         end
         test4=test4+temp41*Wa(i,j)*Da(i,j)/revisedDisa(i,j);
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
 %%elta2 = -2*trace(a'*P2X)+2*lamata1;
 elta2 = -2*test4+2*lamata1;
 segmaX = elta0+elta1+elta2;
 V1a=inv(V1+ones(row_a))-1/(row_a^2)*ones(row_a);
 a1 = V1a*(P1X+P2X)/4;
