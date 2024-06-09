function offset_line = line_offset(line,left_status,radius_)%直线段平移
%偏移直线函数
    offset_line = [0,0,0,0];
    if (line(1) ~= line(3)) && (line(2) ~= line(4))
        k = (line(4)-line(2))/(line(3) - line(1));
        b = line(2) - line(1)*k;
        alpha = atan(k);
        b1 = 0;
        if (line(3) >= line(1)) && (left_status == 0)   % 直线右刀补
            b1 = b - radius_/cos(alpha);
        elseif (line(3)>= line(1)) && (left_status ==1) % 直线左刀补
            b1 = b + radius_/cos(alpha); 
        elseif (line(3) < line(1)) && (left_status ==0) % 直线右刀补
            b1 = b + radius_/cos(alpha);
        elseif (line(3) < line(1)) && (left_status ==1) % 直线左刀补
            b1 = b - radius_/cos(alpha);
        end
        b2 = line(1)/k + line(2);
        b3 = line(3)/k + line(4);
        offset_line(1) = (b2-b1)/(k+(1/k));
        offset_line(2) = k*offset_line(1) + b1;
        offset_line(3) = (b3-b1)/(k+(1/k));
        offset_line(4) = k*offset_line(3) + b1;
    elseif line(1) == line(3) %直线水平
        if (line(4) > line(2)) && (left_status ==1)
            offset_line(1) = line(1) + radius_;
            offset_line(3) = line(3) + radius_;
        elseif (line(4) < line(2)) && (left_status ==1)
            offset_line(1) = line(1) - radius_;
            offset_line(3) = line(3) - radius_;
        elseif (line(4) > line(2)) && (left_status ==0)
            offset_line(1) = line(1) - radius_;
            offset_line(3) = line(3) - radius_;
        elseif (line(4) < line(2)) && (left_status ==0)
            offset_line(1) = line(1) + radius_;
            offset_line(3) = line(3) + radius_;
        end
    elseif line(2) == line(4)%直线竖直
        if (line(3) > line(1)) && (left_status ==1)
            offset_line(2) = line(2) - radius_;
            offset_line(4) = line(4) - radius_;
        elseif (line(3) < line(1)) && (left_status ==1)
            offset_line(2) = line(2) + radius_;
            offset_line(4) = line(4) + radius_;
        elseif (line(3) > line(1)) && (left_status ==0)
            offset_line(2) = line(2) + radius_;
            offset_line(4) = line(4) + radius_;
        elseif (line(3) < line(1)) && (left_status ==0)
            offset_line(2) = line(2) - radius_;
            offset_line(4) = line(4) - radius_;
        end
       offset_line(1) = line(1);
       offset_line(3) = line(3);
    end
end

%left_status,表示左刀补状态
%radius_表示刀补半径