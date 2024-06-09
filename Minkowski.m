function  intersect = Minkowski (cuboidVertices, cylinderCenter, cylinderRadius, cylinderHeight, cylinderAxis)
    % 主函数，检测长方体和圆柱体是否相交
    % cuboidVertices: 8x3 矩阵，表示长方体的8个顶点
    % cylinderCenter: 1x3 向量，表示圆柱体的中心点
    % cylinderRadius: 标量，表示圆柱体的半径
    % cylinderHeight: 标量，表示圆柱体的高度
    % cylinderAxis: 1x3 向量，表示圆柱体的轴向方向
    
    % 定义圆柱体参数
    cylinder = [cylinderCenter, cylinderRadius, cylinderHeight, cylinderAxis];

   % 调用GJK算法
    intersect = GJK(cuboidVertices, cylinder);
end


function intersect = GJK(cuboidVertices, cylinder)
    % 初始化
    direction = [1, 0, 0];%第一个搜索的方向
    simplex = supportMinkowski(@(d) supportCuboid(cuboidVertices, d), @(d) supportCylinder(cylinder, d), direction);
    direction = -simplex;

    while true
        newPoint = supportMinkowski(@(d) supportCuboid(cuboidVertices, d), @(d) supportCylinder(cylinder, d), direction);
        if dot(newPoint, direction) <= 0
            intersect = false;
            return;
        end

        simplex = [simplex; newPoint];
        [containsOrigin, simplex, direction] = checkSimplex(simplex, direction);

        if containsOrigin
            intersect = true;
            return;
        end
    end
end

function [containsOrigin, newSimplex, direction] = checkSimplex(simplex, direction)
    % 检查Simplex是否包含原点，并调整Simplex和方向
    A = simplex(end, :);
    AO = -A;

    if size(simplex, 1) == 3
        B = simplex(1, :);
        C = simplex(2, :);
        AB = B - A;
        AC = C - A;
        ABC = cross(AB, AC);

        if dot(cross(ABC, AC), AO) > 0
            simplex = [A; C];
            direction = cross(cross(AC, AO), AC);
        elseif dot(cross(AB, ABC), AO) > 0
            simplex = [A; B];
            direction = cross(cross(AB, AO), AB);
        else
            if dot(ABC, AO) > 0
                direction = ABC;
            else
                direction = -ABC;
            end
        end
    elseif size(simplex, 1) == 2
        B = simplex(1, :);
        AB = B - A;
        direction = cross(cross(AB, AO), AB);
    end

    containsOrigin = (dot(AO, direction) < 1e-6);
    newSimplex = simplex;
end


function supportPoint = support(vertices, direction)
    % 返回在给定方向上最远的顶点
    [~, idx] = max(vertices * direction');  %返回最大值的索引
    supportPoint = vertices(idx, :); %返回最远距离的坐标值
end


function supportPoint = supportCuboid(cuboidVertices, direction)
    % 长方体的支持函数
    supportPoint = support(cuboidVertices, direction);
end


function supportPoint = supportCylinder(cylinder, direction)
    % 圆柱体的支持函数
    % cylinder = [center, radius, height, axis]
    center = cylinder(1:3);
    radius = cylinder(4);
    height = cylinder(5);
    axis = cylinder(6:8);
    axis = axis / norm(axis); % 归一化轴向量

    % 水平方向最远点
    dirOnPlane = direction - dot(direction, axis) * axis;
    dirOnPlane = dirOnPlane / norm(dirOnPlane);
    horizontalPoint = center + radius * dirOnPlane;

    % 垂直方向最远点
    if dot(direction, axis) > 0
        verticalPoint = center + (height / 2) * axis;
    else
        verticalPoint = center - (height / 2) * axis;
    end

    % 在方向上的最远点
    supportPoint = horizontalPoint + (verticalPoint - horizontalPoint);
end


 % 计算Minkowski差的支持点
function supportPoint = supportMinkowski(A, B, direction)
    % 计算Minkowski差的支持点
    supportPoint = A(direction) - B(-direction);
end
