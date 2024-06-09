function [cross_point1_x,cross_point1_y,cross_point2_x,cross_point2_y]=getCrossPoint(arc1,k1,b1)
%求交点
    c = -1*arc1(1);
    d = -1*arc1(2);
    r = arc1(3);
    cross_point1_x = -1*(((k1^2+1)*r^2-(c*k1)^2+(2*c*d+2*b1*c)*k1-d*d-2*b1*d-b1*b1)+(b1+d)*k1+c)/(k1^2+1);
    cross_point1_y = k1*cross_point1_x+b1;
    cross_point2_x = (((k1^2+1)*r^2-(c*k1)^2+(2*c*d+2*b1*c)*k1-d*d-2*b1*d-b1*b1)-(b1+d)*k1-c)/(k1^2+1);
    cross_point2_y = k1*cross_point2_x+b1;
end