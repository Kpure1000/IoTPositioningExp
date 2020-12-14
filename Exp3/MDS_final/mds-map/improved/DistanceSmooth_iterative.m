%%% function dd=iterative_calculating()
%%% ¾àÀëÆ½»¬µÄµü´ú²âÊÔ³ÌÐò
a0=[0 1.5;-1 0;0 -1;1.2 0];
b=[-2 2;-2 -2;2 -2;2 2];
Da=[0 1.4 2 1.4;1.4 0 1.4 2;2 1.4 0 1.4;1.4 2 1.4 0];
Dab=[2.23 0 0 2.23;2.23 2.23 0 0;0 2.23 2.23 0;0 0 2.23 2.23];
Wa=[0 1 1 1;1 0 1 1;1 1 0 1;1 1 1 0];
Wab=[1 0 0 1;1 1 0 0;0 1 1 0;0 0 1 1];

e = calcuEmax(a0,b,Da,Dab,Wa,Wab);
iterative_time=20;
absolute_error_value=0.01;
initial_value=a0;
e=0;
for i = e:-e/10:0
    k = 0;
    [a1,segmaX0] = DistanceSmoothOptimal(a0,b,Da,Dab,Wa,Wab,e);
    segmaX1 = segmaX0;
    while(k==0|(segmaX0-segmaX1>absolute_error_value&&k<=iterative_time))
          k = k+1;
          segmaX0 = segmaX1;
          a0 = a1;
          [a1,segmaX1] = DistanceSmoothOptimal(a0,b,Da,Dab,Wa,Wab,e);
    end
end
disp(a0);
disp(a1);
disp(segmaX0);
disp(segmaX1);