function start_point = getArcStartPoint(arc)%获取圆弧起点
    start_point = [];
    start_point(1) = arc.arc(1) + arc.radius*cos(deg2rad(arc.arc(4)));%start_point.x
    start_point(2) = arc.arc(2) + arc.radius*sin(deg2rad(arc.arc(4)));%start_point.y
end
