# -
用matlab完成了可以读取dxf文件然后生成相关的加工代码的功能能够识别的元素有直线圆弧和圆,还可以输入加工代码(.txt)生成相关的加工路线(2D和3D),程序还可以监控刀具和胚料是否干涉以及刀具的加工状态
  完成了直线对直线的左刀补的功能,输入dxf文件,得到左刀补的图像  
  广度优先算法对输入图像中的几何体进行排序,能够高效的分辨封闭几何图形
  GJK算法监控刀具与胚料的空间位置与状态
 运行NC.m文件在UI中使用各功能函数
![image](https://github.com/YunYang255/-/assets/119786612/ddd7f8ee-ff3b-4232-94b6-b6cd78f59c06)
读入 DXF 文件并画图的相关函数
用DXFtool函数获取读入DXF文件的内容，DXFtool内部有function h = plot_line(line,col)等可以把起终点的坐标算出来并存到entities的line中。不仅是直线还有圆弧的圆心坐标，半径起终点的角度也可以输出到entities中。DXFtool内还有函数read_dxf(filename)可以将识别到的每一条线的线型识别出来并输出到entities的name中。后续我们通过识别这个可以判断当下作图是需要画直线还是圆弧。
 
图 3.1 DXF读取文件后绘图效果图
  3.2 遍历所有实体生成G代码
函数介绍—generateGCode
function generateGCode(entities, inputFile)
此函数是生成 G 代码的主函数。它读取几何实体，生成相应的 G 代码，并将这些代码写入指定的输出文件.
函数输入参数
entities：结构数组，包含几何特征点的信息。每个结构包含以下字段：
name：几何实体的名称（例如 'LINE'、'ARC'、'CIRCLE'）。
对应实体的几何信息（例如线段的起点和终点坐标、圆弧的中心和半径等）。
inputFile：输出的 G 代码文件路径.
函数主体介绍:
% generateGCode 根据几何特征点生成数控加工的G代码和M代码
    % entities - 存储几何特征点的结构数组
    % outputFile - 输出的G代码文件路径
    % 打开文件以写入G代码
    fid = fopen(inputFile, 'wt');
    if fid == -1
        error('Cannot open file: %s', inputFile);
    end
    % 写入文件头部
    fprintf(fid, '%% G代码生成\n');
    fprintf(fid, 'G21 ; 设置单位为毫米\n');
    fprintf(fid, 'G90 ; 绝对坐标编程\n');
    fprintf(fid, 'G17 ; 选择X-Y平面\n');
    duidaox = evalin('base', 'duidaox');
    duidaoy = evalin('base', 'duidaoy');
    duidaoz = evalin('base', 'duidaoz');
    fprintf(fid, 'G00 X%.3f Y%.3f Z%.3f;快速对刀到对刀点\n',duidaox,duidaoy, duidaoz); %计算直线起点坐标
    Start = entities(1);
    speed = evalin('base', 'speed');
    fast = evalin('base', 'fast');
    deep = evalin('base', 'deep');
    if strcmp (Start.name, 'LINE')
       fprintf(fid, 'G00 X%.3f Y%.3f Z%.3f;快速对刀\n',Start.line(1,1),Start.line(1,2) , -deep); %计算直线起点坐标
    x_d=Start.line(1,1);
    y_d=Start.line(1,2);
    elseif strcmp (Start.name, 'ARC')
        [x,y]=coordinate_calculation(Start.arc(1,4), Start.arc(1,1), Start.arc(1,2), Start.arc(1,3));  %计算圆弧起点坐标
       fprintf(fid, 'G00 X%.3f Y%.3f Z%.3f;\n',x,y,-deep);
    x_d=x;
    y_d=y;
    elseif strcmp (Start.name, 'CIRCLE')
        x=Start.circle(1,1)+Start.circle(1,3);
        y=Start.circle(1,2);
       fprintf(fid, 'G00 X%.3f Y%.3f Z%.3f;\n',x,y,-deep);
    x_d=x;
    y_d=y;
    end
    % 遍历所有实体生成相应的G代码
  for i = 1:length(entities)
    e = entities(i);
      if (i==1)
          [x_d , y_d] = processEntity_with_S_and_F(e, x_d, y_d , speed , fast,deep,fid);
      else 
          [x_d, y_d] = processEntity(e, x_d, y_d,deep, fid);
      end
  end
    % 写入文件尾部
    fprintf(fid, 'G40 ; 取消刀补\n');
    fprintf(fid, 'M30 ; 程序结束\n');
    % 关闭文件
    fclose(fid);
    fprintf('G代码已生成并保存到文件: %s\n', inputFile);
函数主要通过processEntity_with_S_and_F(见附录)以及processEntity(见附录)函数来处理整个传入的实体.
首先打开一个用于写入的文件，如果文件无法打开则抛出错误。Fid是一个文件标识符，用于后续文件操作.
然后通过写入 G 代码文件的头部信息，包括单位设置、坐标编程方式和平面选择。
G21：设置单位为毫米。
G90：选择绝对坐标编程。
G17：选择 X-Y 平面。
duidaox = evalin('base', 'duidaox');
duidaoy = evalin('base', 'duidaoy');
duidaoz = evalin('base', 'duidaoz');
fprintf(fid, 'G00 X%.3f Y%.3f Z%.3f;快速对刀到对刀点\n', duidaox, duidaoy, duidaoz);
从 MATLAB 基础工作区中获取对刀点坐标，并生成相应的快速对刀 G 代码.
接着是处理第一个几何实体，根据其类型（LINE, ARC, CIRCLE）生成相应的 G 代码，并初始化刀具的当前位置。
Start = entities(1);
speed = evalin('base', 'speed');
fast = evalin('base', 'fast');
deep = evalin('base', 'deep');
if strcmp(Start.name, 'LINE')
    fprintf(fid, 'G00 X%.3f Y%.3f Z%.3f;快速对刀\n', Start.line(1,1), Start.line(1,2), -deep);
    x_d = Start.line(1,1);
    y_d = Start.line(1,2);
elseif strcmp(Start.name, 'ARC')
    [x, y] = coordinate_calculation(Start.arc(1,4), Start.arc(1,1), Start.arc(1,2), Start.arc(1,3));
    fprintf(fid, 'G00 X%.3f Y%.3f Z%.3f;\n', x, y, -deep);
    x_d = x;
    y_d = y;
elseif strcmp(Start.name, 'CIRCLE')
    x = Start.circle(1,1) + Start.circle(1,3);
    y = Start.circle(1,2);
    fprintf(fid, 'G00 X%.3f Y%.3f Z%.3f;\n', x, y, -deep);
    x_d = x;
    y_d = y;
end
遍历所有几何实体并生成相应的 G 代码
for i = 1:length(entities)
    e = entities(i);
    if i == 1
        [x_d, y_d] = processEntity_with_S_and_F(e, x_d, y_d, speed, fast, deep, fid);
    else 
        [x_d, y_d] = processEntity(e, x_d, y_d, deep, fid);
    end
end
写入 G 代码文件的尾部信息，包括取消刀补和结束程序命令，然后关闭文件.
fprintf(fid, 'G40 ; 取消刀补\n');
fprintf(fid, 'M30 ; 程序结束\n');
fclose(fid);
fprintf('G代码已生成并保存到文件: %s\n', inputFile);
processEntity函数详解
处理直线（LINE）:
case 'LINE'
    x_end = e.line(2,1);
    y_end = e.line(2,2);
    fprintf(fid, 'G01 X%.3f Y%.3f Z%.3f;\n', x_end, y_end, -deep);
    x_d = x_end;
y_d = y_end;
获取直线的终点坐标 x_end 和 y_end。
写入直线的 G 代码命令 G01，用于直线插补。
更新刀具的当前位置 x_d 和 y_d.
