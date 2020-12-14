function  Emax = calcuEmax(a,b,Da,Dab,Wa,Wab)
%%% 这是计算距离平滑中的阈值
     row_a = size(a,1);
     row_b = size(b,1);
     e = zeros(1,row_a);
     w = zeros(1,row_a);
     v = zeros(1,row_a);
     WDa = zeros(1,row_a);
     VDab = zeros(1,row_a);
for i = 1:row_a
    for j = 1:row_a
        w(i) = w(i)+Wa(i,j);
        WDa(i) = WDa(i)+Wa(i,j)*Da(i,j);
    end
    for k = 1:row_b
        v(i) = v(i)+Wab(i,k);
        VDab(i) = VDab(i)+Wab(i,k)*Dab(i,k);
    end
    e(i) = (WDa(i)+VDab(i))/(w(i)+v(i));
end
    Emax = 0.6922*sqrt(2)*max(e);