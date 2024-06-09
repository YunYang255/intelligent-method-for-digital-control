
function end_point = getArcEndPoint(arc)%获取圆弧终点
    end_point = [0,0];
    end_point(1) = arc(1) + arc(3)*cos(deg2rad(arc(5)));
    end_point(2) = arc(2) + arc(3)*sin(deg2rad(arc(4)));
end