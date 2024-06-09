function line1 = getArcLine1(arc)
    endpoint = getArcEndPoint(arc);
    zeropoint = [arc(1),arc(2)];
    slope = (zeropoint(2) - endpoint(2))/(zeropoint(1)-endpoint(1));
    k_line1 = -1/slope;
    b_line1 = end_point(2)-k_line1*endpoint(1);
    angle_point1 = arc(4) + (arc(5)-arc(4))/4;
    x_point1 = arc(1) + arc(3)*cos(deg2rad(angle_point1));
    y_point1 = x_point1*k_line1 + b_line1;
    line1 = [x_point1,y_point1,endpoint(1),endpoint(2)];
end