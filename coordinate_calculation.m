% 根据圆弧的角度求坐标值
function [arc_start_x, arc_start_y] = coordinate_calculation(arc, x, y, R)
    if  (arc == 0)
        arc_start_x =x+R;
        arc_start_y = y;
    elseif (arc == 90)
        arc_start_x = x;
        arc_start_y = y+R;
    elseif (arc == 180)
        arc_start_x= x-R;
        arc_start_y = y;
    elseif (arc == 270)
        arc_start_x = x;
        arc_start_y = y-R;
    elseif (arc == 360)
        arc_start_x = x+R;
        arc_start_y = y ;
    elseif (arc > 0 && arc < 90)
        arc_start_x = x + R * cosd(arc);
        arc_start_y = y + R * sind(arc);
    elseif (arc > 90 && arc < 180)
        arc_start_x = x - R * cosd(180 - arc);
        arc_start_y = y + R * sind(180 - arc);
    elseif (arc > 180 && arc < 270)
        arc_start_x = x - R * cosd(arc - 180);
        arc_start_y = y - R * sind(arc - 180);
    elseif (arc > 270 && arc < 360)
        arc_start_x = x + R * sind(arc - 270);
        arc_start_y = y - R * cosd(arc - 270);
    end
end  



