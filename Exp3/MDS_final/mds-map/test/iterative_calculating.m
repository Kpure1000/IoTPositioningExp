%%% function dd=iterative_calculating()
%%%%这个是在写程序过程中写的矩阵重复迭代的算法流程测试程序
a0=[0 1.5;-1 0;0 -1;1.2 0];
b=[-2 2;-2 -2;2 -2;2 2];
Da=[0 1.4 2 1.4;1.4 0 1.4 2;2 1.4 0 1.4;1.4 2 1.4 0];
Dab=[2.23 0 0 2.23;2.23 2.23 0 0;0 2.23 2.23 0;0 0 2.23 2.23];
Wa=[0 1 1 1;1 0 1 1;1 1 0 1;1 1 1 0];
Wab=[1 0 0 1;1 1 0 0;0 1 1 0;0 0 1 1];
iterative_time=20;
absolute_error_value=0.01;
initial_value=a0;
[a1,segmaX0]=matrix_optimal(a0,b,Da,Dab,Wa,Wab);
segmaX1=segmaX0;
k=0;
while(k==0|(segmaX0-segmaX1>absolute_error_value&&k<=iterative_time))
    k=k+1;
    segmaX0=segmaX1;
    a0=a1;
    [a1,segmaX1]=matrix_optimal(a0,b,Da,Dab,Wa,Wab);
end
disp(a0);
disp(segmaX0);
disp(segmaX1);