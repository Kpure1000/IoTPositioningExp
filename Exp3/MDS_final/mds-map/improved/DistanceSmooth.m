function H = DistanceSmooth(t,e)
%%%������Ǿ���ƽ��������
if (abs(t)<e)
    H = t^2/(2*e) + e/2;
else
    H = abs(t);
end