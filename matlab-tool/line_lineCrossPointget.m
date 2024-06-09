function point = line_lineCrossPointget(line1,line2)%获取直线-直线刀补交点
    k1 = (line1(2)-line1(4))/(line1(1)-line1(3));
    k2 = (line2(2)-line2(4))/(line2(1)-line2(3));
    b1 = line1(2) - k1*line1(1);
    b2 = line2(2) - k2*line2(1);
    point(2) = (k1*b2-k2*b1)/(k1-k2);
    point(1) = (b1-b2)/(k2-k1);
end