function offsetarc = arcoffset(arc,left_status,radius_)%圆弧轨迹补偿
    offsetarc = [0,0,0,0,0];
    if ((arc(5) - arc(4)) < 0) && (left_status == 1)
        offsetarc = [arc(1),arc(2),arc(3) - radius_,arc(4),arc(5)];
    elseif (arc(5) - arc(4) < 0) && (left_status == 0)
        offsetarc = [arc(1),arc(2),arc(3) + radius_,arc(4),arc(5)];
    elseif (arc(5) - arc(4) >= 0) && (left_status == 1)
        offsetarc = [arc(1),arc(2),arc(3) + radius_,arc(4),arc(5)];
    elseif (arc(5) - arc(4) >= 0) && (left_status == 0)
        offsetarc = [arc(1),arc(2),arc(3) - radius_,arc(4),arc(5)];
    end
end