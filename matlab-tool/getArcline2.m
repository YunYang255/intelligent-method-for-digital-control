function line = getArcline2(arc)%直线与弧线
    startpoint = getArcStartPoint(arc);
    zeropoint = [arc(1),arc(2)];
    slope = (zeropoint(2) - startpoint(2))/(zeropoint(1) - startpoint(1));
    k_line2 = -1/slope;
    b_line2 = startpoint(2) - startpoint(1)*k_line2;
    angle_point2 = arc(4) + (arc(5)-arc(4))/4;
    x_point2 = arc(1) + arc(3)*cos(deg2rad(angle_point2));
    y_point2 = k_line2*x_point2 + b_line2;
    line = [startpoint(1),startpoint(2),x_point2,y_point2];
end