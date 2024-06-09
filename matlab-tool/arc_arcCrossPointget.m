function cross_points = arc_arcCrossPointget(arc1,arc2)%获取圆弧-圆弧交点,检查调用处
    c1 = arc1.arc(1);
    d1 = arc1.arc(2);
    r1 = arc1.arc(3);
    c2 = arc2.arc(1);
    d1 = arc2.arc(2);
    r2 = arc2.arc(3);
    k = (c2-c1)/(d1-d2);
    b = (c1^2-c2^2+d1^2-d2^2+r2^2-r1^2)/(2*(d1-d2));
    cross_points = getCrossPoint(arc1,k,b);
end
