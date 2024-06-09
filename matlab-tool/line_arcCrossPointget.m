function cross_point =line_arcCrossPointget(line1,arc1)%获取直线-圆弧刀补交点
    k1 = (line1(1,2)-line1(1,4))/(line1(1,1)-line1(1,3));
    b1 = line1(1,2) - k1*line1(1,1);
    c = -1*arc1(1);
    d = -1*arc1(2);
    r = arc1(3);
    cross_point(1) = -1*(((k1^2+1)*r^2-(c*k1)^2+(2*c*d+2*c*b1)*k1-d^2-2*b1*d-b1^2)^0.5+(b1+d)*k1+c)/(k1^2 + 1);
    cross_point(2) = k1*cross_point(1) + b1;
    cross_point(3) = (((k1^2+1)*r^2-(c*k1)^2+(2*c*d+2*c*b1)*k1-d^2-2*b1*d-b1^2)^0.5+(b1+d)*k1+c)/(k1^2 + 1);
    cross_point(4) = k1*cross_point(3) + b1;
end