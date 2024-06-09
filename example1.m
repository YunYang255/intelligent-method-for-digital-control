%% DXFtool example 1: Showing off possibilities

clc; close all;

% read file and plot
dxf = DXFtool('C:\Users\Administrator\Desktop\DXFtool_v1.0\DXFtool_v1.0\matlab-tool\matlab-tool\testing_filelhn.dxf');

% list the imported entities
dxf.list;

%% 函数主体

entities = dxf.entities;

entities = BFS(entities);

% 生成G代码

generateGCode(entities, 'C:\Users\Administrator\Desktop\DXFtool_v1.0\DXFtool_v1.0\output.txt');

generateGCode2(entities, 'C:\Users\Administrator\Desktop\DXFtool_v1.0\DXFtool_v1.0\output2.txt');

fixOffsetPath2(entities);
%% 调用函数显示刀具路径
plot_tool_path('C:\Users\Administrator\Desktop\DXFtool_v1.0\DXFtool_v1.0\output.txt');

%% 调用函数显示刀具行进动画
create_tool_path_animation_3D('C:\Users\Administrator\Desktop\DXFtool_v1.0\DXFtool_v1.0\output.txt');