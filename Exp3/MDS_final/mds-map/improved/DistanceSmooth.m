function H = DistanceSmooth(t,e)
%%%这个就是距离平滑函数了
if (abs(t)<e)
    H = t^2/(2*e) + e/2;
else
    H = abs(t);
end