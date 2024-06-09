function angle = countVectorAnlge(line1,line2,left_status,radius_)%计算直线段间矢量夹角，传入参数均为向量
    c = sqrt((line2(4) - line1(2))^2 + (line2(3) - line1(1))^2);
    a = sqrt((line1(4) - line1(2))^2 + (line1(3) - line1(1))^2);
    b = sqrt((line2(4) - line2(2))^2 + (line2(3) - line2(1))^2);
    cosA = (a^2+b^2-c^2)/(2*a*b);
    angle = rad2deg(acos(cosA));
    offset_line1 = line_offset(line1,left_status,radius_);
    x_direction = line2(3) - line1(1);
    y_direction = line2(4) - line1(2);
    x_change = offset_line1(1) - line1(1);
    y_change = offset_line1(2) - line1(2);
    cosB = (x_direction*x_change)+(y_change*y_direction);
    if (cosB > 0)
        angle = 360 - angle;
    end
end

%left_status,表示左刀补状态
%radius_表示刀补半径