

function fixed_path =fixOffsetPath(offset1,offset2,angle)%获取刀具中心轨迹
%判断直线类型并获取刀补线段
    if strcmp(offset1, 'LINE') && strcmp(offset2, 'LINE')%线段-线段转接
        if angle >=180%缩短型
            cross_point = line_lineCrossPointget(offset1.line,offset2.line);
            fixed_path1.line(3) = cross_point(1);
            fixed_path1.line(4) = cross_point(2);
            fixed_path2.line(1) = cross_point(1);
            fixed_path2.line(2) = cross_point(2);
        fixed_path = [fixed_path1,fixed_path2];
        elseif angle>= 90 && angle < 180%伸长型
            cross_point = line_lineCrossPointget(offset1.line,offset2.line);
            fixed_path1.line(3) = cross_point(1);
            fixed_path1.line(4) = cross_point(2);
            fixed_path2.line(1) = cross_point(1);
            fixed_path2.line(2) = cross_point(2);
         fixed_path = [fixed_path1,fixed_path2];   
        elseif angle <= 90%插入型
            k1 = (offset1.line(2)-offset1.line(4))/(offset1.line(1)-offset1.line(3));
            b1 = offset1.line(2) - offset1.line(1)*k1;
            k2 = (offset2.line(2) - offset2.line(4))/(offset2.line(1)-offset2.line(3));
            b2 = offset2.line(2) - offset2.line(1)*k1;
            extendx11 = (radius_^2/(k1^2+1))^0.5+offset1.line(3);
            extendx12 = -1*(radius_^2/(k1^2+1))^0.5+offset1.line(3);
            if (extendx11 - offset1.line(3))/(offset1.line(3)-offset2.line(1))>0
                extend_point1(1) = extendx11;
            else
                extend_point1(1) = extendx12;
            end
            extend_point1(2) = k1*extend_point1(1)+b1;
            extendx21 = (radius_^2/(k2^2+1))^0.5 + offset2.line(1);
            extendx22 = -1*(radius_^2/(k2^2+1))^0.5 + offset2.line(1);
            if (extendx21 - extendx22)/(offset2.line(1)-offset2.line(3)) >= 0
                extend_point2(1) = extendx21;
            else
                extend_point2(1) = extendx22;
            end
            extend_point2(2) = extend_point2(1)*k2 +b2;
            fixed_path1(3) = extend_point1(1);
            fixed_path1(4) = extend_point1(2);
            fixed_path3(1) = extend_point2(1);
            fixed_path3(2) = extend_point2(2);
            fixed_path2(1) = fixed_path1(3);
            fixed_path2(2) = fixed_path1(4);
            fixed_path2(3) = fixed_path3(1);
            fixed_path2(4) = fixed_path3(2);
            fixed_path = [fixed_path1,fixed_path2,fixed_path3];
        end
    elseif strcmp(offset1, 'LINE') && strcmp(offset2, 'ARC')%线段-圆弧转接
        line1 = offset1.line;
        arc1 = offset2.arc;
        if angle>=180 %缩短型
            cross_points = line_arcCrossPointget(line1,arc1);
            cross_point1 = cross_points(1);
            cross_point2 = cross_points(2);
            cross_angle1_ = acos((cross_point1(1)-arc1(1))/arc1(3));
            cross_angle2_ = acos((cross_point2(1)-arc1(1))/arc1(3));
            cross_angle1 = rad2deg(cross_angle1_);
            cross_angle2 = rad2deg(cross_angle2_);
            cross_angle1 = getCloseAngle(cross_angle1,arc1(4));
            cross_angle2 = getCloseAngle(cross_angle2,arc1(4));
            if abs(cross_angle1-arc1(4)) > abs(cross_angle2-arc1(4))
                cross_angle = cross_angle1;
                cross_point = cross_point1;
            else
                cross_angle = cross_angle2;
                cross_point = cross_point2;
            end
            fixed_path1.line(1) = line1(1);
            fixed_path1.line(2) = line1(2);
            fixed_path1.line(3) = cross_point(1);
            fixed_path1.line(4) = cross_point(2);

            fixed_path2.arc(1) = acr1(1);
            fixed_path2.arc(2) = arc1(2);
            fixed_path2.arc(3) = arc1(3);
            fixed_path2.arc(4) = cross_angle;
            fixed_path2.arc(5) = arc1(5);
            fixed_path = [fixed_path1,fixed_path2];
           elseif angle >= 90 && angle < 180%伸长型
            cross_points = line_arcCrossPointget(line1,arc1);
            cross_point1 = cross_points(1);
            cross_point2 = cross_points(2);
            cross_angle1_ = acos((cross_point1(1)-arc1(1))/(arc1(3)));
            cross_angle2_ = acos((cross_point2(1)-arc1(1))/(arc1(3)));
            cross_angle1 = rad2deg(cross_angle1_);
            cross_angle2 = rad2deg(cross_angle2_);
            if abs(cross_angle1 - arc1(4)) < abs(cross_angle2 - arc1(4))
                cross_angle = cross_angle1;
                cross_point = cross_point1;
            else
                cross_angle = cross_angle2;
                cross_point = cross_point2;
            end
            fixed_path1.line = [line1(1),line1(2),cross_point(1),cross_point(2)];
            fixed_path2.arc = [arc1(1),arc1(2),arc1(3),cross_angle,arc1(5)];
            fixed_path = [fixed_path1,fixed_path2];
        elseif angle < 90%插入型
            %修复直线段
            k = (line1(2) - line1(4))/(line1(1) - line1(3));
            b = line1(2) - k*line1(1);
            extendedx1 = (radius_^2/(k^2+1))+line1(3);
            extendedx2 = -1*(radius_^2/(k^2+1))+line1(3);
            if (extendedx1 - line1(3))/(line1(3) - line1.(1)) >= 0
                extended_point(1) = extendedx1;
            else
                extended_point(1) = extendedx2;
            end
            extended_point(2) = k*extended_point(1) + b;
            line1(3) = extended_point(1);
            line1(4) = extended_point(2);
            %修复圆弧段
            start_point = getArcStartPoint(arc1);
            arc3(1) = start_point(1);
            arc3(2) = start_point(2);
            arc3(3) = radius_;
            arc3(4) = 0;
            arc3(5) = 359;
            cross_points = arc_arcCrossPointget(arc1,arc3);
            cross_point1 = cross_points(1);
            cross_point2 = cross_points(2);
            cross_angle1_ = acos((cross_point1(1)-arc1(1))/(arc1(3)));
            cross_angle2_ = acos((cross_point2(1)-arc1(1))/(arc1(3)));
            cross_angle1 = rad2deg(cross_angle1_);
            cross_angle2 = rad2deg(cross_angle2_);
            cross_angle1 = getCloseAngle(cross_angle1,arc1(4));
            cross_angle2 = getCloseAngle(cross_angle2,arc1(4));
            if abs(cross_angle1 - arc1(4)) < abs(cross_angle2 - arc1(4))
                cross_angle = cross_angle1;
                cross_point = cross_point1;
            else 
                cross_angle = cross_angle2;
                cross_point = cross_point2;
            end
            fixed_path1.line = line1;
    
            fixed_path2.line(1) = line1(3);
            fixed_path2.line(3) = cross_point(1);
            fixed_path2.line(2) = line1(4);
            fixed_path2.line(4) = cross_point(2);
    
            fixed_path3.arc(1) = arc1(1);
            fixed_path3.arc(2) = arc1(2);
            fixed_path3.arc(3) = arc1(3);
            fixed_path3.arc(4) = cross_angle;
            fixed_path3.arc(5) = arc1(5);
            fixed_path = [fixed_path1,fixed_path2,fixed_path3];
        end
   
    elseif strcmp(offset1, 'ARC') && strcmp(offset2, 'ARC')%圆弧-圆弧
        arc1 = offset1.arc;
        arc2 = offset2.arc;
        if angle > 180%缩短型
            cross_points = arc_arcCrossPointget(arc1,arc2);
            cross_point1 = cross_points(1);
            cross_point2 = cross_points(2);
            cross_angle11 = rad2deg(acos((cross_point1(1) - arc1(1))/arc1(3)));
            cross_angle12 = rad2deg(acos((cross_point2(1) - arc1(1))/arc1(3)));
            cross_angle11 = getCloseAngle(cross_angle11,arc1(5));
            cross_angle12 = getCloseAngle(cross_angle12,arc1(5));
            dis_p11 = abs(cross_angle11 - arc1(5)) + abs(cross_angle11 - arc2(4));
            dis_p12 = abs(cross_angle12 - arc1(5)) + abs(cross_angle12 - arc2(4));
            if dis_p11 < dis_p12
                cross_angle1 = cross_angle11;
            else
                cross_angle1 = cross_angle12;
            end
            cross_angle21 = rad2deg(acos((cross_point1(1) - arc2(1))/arc2(3)));
            cross_angle22 = rad2deg(acos(cross_point2(1) - arc2(1))/arc2(3));
            cross_angle21 = getCloseAngle(cross_angle21,arc2(5));
            cross_angle22 = getCloseAngle(cross_angle22,arc2(5));
            dis_p21 = abs(cross_angle21 - arc1(5)) + abs(cross_angle21 - arc2(5));
            dis_p22 = abs(cross_angle22 - arc1(5)) + abs(cross_angle22 - arc2(5));
            if dis_p21 < dis_p22
                cross_angle2 = cross_angle21;
            else 
                cross_angle2 = cross_angle22;
            end
            fixed_path1.arc(1) = arc1(1);
            fixed_path1.arc(2) = arc1(2);
            fixed_path1.arc(3) = arc1(3);
            fixed_path1.arc(4) = arc1(4);
            fixed_path1.arc(5) = cross_angle1;

            fixed_path2.arc(1) = arc2(1);
            fixed_path2.arc(2) = arc2(2);
            fixed_path2.arc(3) = arc2(3);
            fixed_path2.arc(4) = cross_angle2;
            fixed_path2.arc(5) = arc2(5);
            fixed_path = [fixed_path1,fixed_path2];
        elseif (angle >= 90) && (angle <= 180)%伸长型
            cross_points = arc_arcCrossPointget(arc1,arc2);
            cross_point1(1) = cross_points(1);
            cross_point1(2) = cross_points(2);
            cross_point2(1) = cross_points(3);
            cross_point2(2) = cross_points(4);
            cross_angle11 = rad2deg(acos((cross_point1(1) - arc1(1))/arc1(3)));
            cross_angle12 = rad2deg(acos((cross_point2(1) - arc1(1))/arc1(3)));
            cross_angle11 = getCloseAngle(cross_angle11,arc1(5));
            cross_angle12 = getCloseAngle(cross_angle12,arc1(5));
            dis_p11 = abs(cross_angle11 - arc1(5)) + abs(cross_angle11 - arc2(4));
            dis_p12 = abs(cross_angle12 - arc1(5)) + abs(cross_angle12 - arc2(4));
            if dis_p11 < dis_p12
                cross_angle1 = cross_angle11;
            else
                cross_angle1 = cross_angle12;
            end
            cross_angle21 = rad2deg(acos((cross_point1(1) - arc2(1))/arc2(3)));
            cross_angle22 = rad2deg(acos((cross_point2(1) - arc2(1))/arc2(3)));
            cross_angle21 = getCloseAngle(cross_angle21,arc2(4));
            cross_angle22 = getCloseAngle(cross_angle22,arc2(4));
            dis_p21 = abs(cross_angle21 - arc1(5)) + abs(cross_angle21 - arc2(4));
            dis_p22 = abs(cross_angle22 - arc1(5)) + abs(cross_angle22 - arc2(4));
            if dis_p21 < dis_p22
                cross_angle2 = cross_angle21;
            else
                cross_angle2 = cross_angle22;
            end
            fixed_path1.arc = [arc1(1),arc1(2),arc1(3),arc1(4),cross_angle1];
            fixed_path2.arc = [arc2(1),arc2(2),arc2(3),cross_angle2,arc2(5)];
            fixed_path = [fixed_path1,fixed_path2];
        elseif angle < 90 %插入型
            end_point = getArcEndPoint(arc1);
            arc3 = [end_point(1),end_point(2),radius_,0,359];
            
            cross_points1 = arc_arcCrossPointget(arc1,arc3);
            cross_point11(1) = cross_points1(1);
            cross_point11(2) = cross_points1(2);
            cross_point12(1) = cross_points1(3);
            cross_point12(2) = cross_points1(4);
            cross_angle11 = rad2deg(acos((cross_point11(1)-arc1(1))/arc1(3)));
            cross_angle12 = rad2deg(acos((cross_point12(1)-arc1(1))/arc1(3)));
            cross_angle11 = getCloseAngle(cross_angle11,arc1(5));
            cross_angle12 = getCloseAngle(cross_angle12,arc1(5));
            if (cross_angle11 -arc1(5))/(arc1(5)-arc1(4)) > 0
                cross_angle1 = cross_angle11;
                cross_point1 = cross_point11;
            else
                cross_angle1 = cross_angle12;
                cross_point1 = cross_point12;
            end
            start_point = getArcStartPoint(arc2);
            arc4 = [start_point(1),start_point(2),radius_,0,359];
            cross_points2 = arc_arcCrossPointget(arc2,arc4);%此处与对应函数有冲突
            cross_point21(1) = cross_points2(1);
            cross_point21(2) = cross_points2(2);
            cross_point22(1) = cross_points2(3);
            cross_point22(2) = cross_points2(4);
            cross_angle21 = rad2deg(acos((cross_point21(1)-arc2(1))/arc2(3)));
            cross_angle22 = rad2deg(acos((cross_point22(1)-arc2(1))/arc2(3)));
            cross_angle21 = getCloseAngle(cross_angle21,arc2(4));
            cross_angle22 = getCloseAngle(cross_angle22,arc2(4));
            if (cross_angle21- arc2(4))/(arc2(4)-arc2(5)) > 0
                cross_angle2 = cross_angle21;
                cross_point2 = cross_point21;
            else
                cross_angle2 = cross_angle22;
                cross_point2 = cross_point22;
            end
            fixed_path1.arc = [arc1(1),arc1(2),arc1(3),arc1(4),cross_angle1];
            fixed_path2.line = [cross_point1(1),cross_point1(2),cross_point2(1),cross_point2(2)];
            fixed_path3.arc = [arc2(1),arc2(2),arc2(3),cross_angle2,arc2(5)];
            fixed_path = [fixed_path1,fixed_path2,fixed_path3];
        end
    end 
    
end
