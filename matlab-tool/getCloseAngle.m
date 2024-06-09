function get_angle = getCloseAngle(angle,compare)
    p1 = 360 + angle;
    p2 = 360 - anlge;
    p3 = angle - 360;
    p4 = angle;
    p5 = -1*angle;
    if abs(p1 - compare) > abs(p2 - compare)
        middle_angle1 = p2;
    else
        middle_angle1 = p1;
    end
    if abs(p3-compare) > abs(p4 -compare)
        middle_angle2 = p4;
    else
        middle_angle2 = p3;
    end
    if abs(p5 - compare) > abs(middle_angle2 - compare)
        middle_angle2 = p5;
    end
    if abs(middle_angle1 - compare) > abs(middle_angle2-compare)
        get_angle = middle_angle2;
    else
        get_angle = middle_angle1;
    end
end
