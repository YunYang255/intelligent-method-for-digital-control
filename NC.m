function varargout = NC(varargin)
% NC MATLAB code for NC.fig
%      NC, by itself, creates a new NC or raises the existing
%      singleton*.
%
%      H = NC returns the handle to a new NC or the handle to
%      the existing singleton*.
%
%      NC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NC.M with the given input arguments.
%
%      NC('Property','Value',...) creates a new NC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NC_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NC_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NC

% Last Modified by GUIDE v2.5 30-May-2024 20:18:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NC_OpeningFcn, ...
                   'gui_OutputFcn',  @NC_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before NC is made visible.
function NC_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NC (see VARARGIN)

% Choose default command line output for NC
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
deep = 0;
speed = 0;
fast = 0;
assignin('base', 'deep', deep);
assignin('base', 'fast', fast);
assignin('base', 'speed', speed);
% UIWAIT makes NC wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NC_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.uipanel1,'visible','on')

set(handles.uipanel2,'visible','off')

set(handles.uipanel3,'visible','off')

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.uipanel2,'visible','on')

set(handles.uipanel3,'visible','off')

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.uipanel2,'visible','on')
set(handles.uipanel3,'visible','on')

% --- Executes on button press in importbotton.
function importbotton_Callback(hObject, eventdata, handles)
% hObject    handle to importbotton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 获取用户选择的文件
[filename, pathname] = uigetfile('*.dxf', '选择DXF文件');

if isequal(filename, 0) || isequal(pathname, 0)
    % 用户取消选择
    return;
end
fullFilePath = fullfile(pathname, filename);
dxf = DXFtool(fullFilePath);

handles.dxf = dxf;
assignin('base', 'dxf',dxf);
handles.filename = filename;
handles.pathname = pathname;

guidata(hObject, handles); % 更新 handles 结构体

% 显示选择的文件名
set(handles.filenametextbox, 'String', filename);



% --- Executes on button press in generationcodebotton.
function generationcodebotton_Callback(hObject, eventdata, handles)
% hObject    handle to generationcodebotton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

speed = evalin('base', 'speed');
fast = evalin('base', 'fast');

%设置变量通过静态文本框是否有内容判断是否已经读入dxf文件
filenamejudge = get(handles.filenametextbox,'String');

%判断是否输入相关参数及导入dxf文件,如果没有则弹出警报
if (speed == 0 || fast == 0||isempty(filenamejudge))
    % 如果变量没有值，弹出警告框
    errordlg('没有正确输入参数或导入相关文件。', '警告');
else

handles.dxf.list;

entities = handles.dxf.entities;

entities = BFS(entities);


%生成G代码
Pway = evalin('base', 'Pway');
if(Pway == 1)
generateGCode(entities, ' C:\Users\Administrator\Desktop\DXFtool_v1.0\DXFtool_v1.0\output.txt');
%读取生成的G代码并显示到软件上
Gcode = fileread( ' C:\Users\Administrator\Desktop\DXFtool_v1.0\DXFtool_v1.0\output.txt');
set(handles.Gcodebox,'String',Gcode, 'HorizontalAlignment', 'left');
else
generateGCode2(entities, 'C:\Users\Administrator\Desktop\DXFtool_v1.0\DXFtool_v1.0\output2.txt');
%读取生成的G代码并显示到软件上
Gcode = fileread( ' C:\Users\Administrator\Desktop\DXFtool_v1.0\DXFtool_v1.0\output2.txt');
set(handles.Gcodebox,'String',Gcode, 'HorizontalAlignment', 'left');
end

%生成走刀路径图像
plot_tool_path('C:\Users\Administrator\Desktop\DXFtool_v1.0\DXFtool_v1.0\output.txt');

end
 

% --- Executes during object creation, after setting all properties.
function InputFigure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InputFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate InputFigure




function deep_inter_Callback(hObject, eventdata, handles)
% hObject    handle to deep_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of deep_inter as text
%        str2double(get(hObject,'String')) returns contents of deep_inter as a double


% --- Executes during object creation, after setting all properties.
function deep_inter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to deep_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function fast_inter_Callback(hObject, eventdata, handles)
% hObject    handle to fast_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fast_inter as text
%        str2double(get(hObject,'String')) returns contents of fast_inter as a double


% --- Executes during object creation, after setting all properties.
function fast_inter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fast_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function speed_inter_Callback(hObject, eventdata, handles)
% hObject    handle to speed_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of speed_inter as text
%        str2double(get(hObject,'String')) returns contents of speed_inter as a double


% --- Executes during object creation, after setting all properties.
function speed_inter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to speed_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveValueBotton.
function SaveValueBotton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveValueBotton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%获取切削深度
deep_ = get(handles.deep_inter, 'String');
% 获取进给速度
fast_ = get(handles.fast_inter, 'String');   
% 获取主轴转速
speed_ = get(handles.speed_inter, 'String');
% 获取刀补方式,2是左刀补,3是右刀补,1报错
compensation_way_= get(handles.compensation_inter, 'Value');
% 获取刀具号码 1号刀具是2,2号刀具是3,以此类推
tool_num_ = get(handles.tool_choosing, 'Value');
%获取编程方式代码
Pway_ = get(handles.Pway_inter,'Value');
%获取对刀点x坐标
duidaox_= get(handles.duidaox_inter,'String');
%获取对刀点y坐标
duidaoy_= get(handles.duidaoy_inter,'String');
%获取对刀点xz坐标
duidaoz_= get(handles.duidaoz_inter,'String');
%获取加工方向
direction = get(handles.popupmenu4,'Value');
% 存储到变量中
    speed_ = str2double(speed_);
    fast_ = str2double(fast_);
    deep_ = str2double(deep_);
    duidaox_ = str2double(duidaox_);
    duidaoy_ = str2double(duidaoy_);
    duidaoz_ = str2double(duidaoz_);
    % 判断输入的是否是数字
    if (isnan(speed_) || isnan(fast_) || isnan(deep_)||(tool_num_ == 1)||(compensation_way_ == 1)||(Pway_ == 1))
        % 如果输入不是有效的数字，弹出警告框
        errordlg('没有正确输入相关参数或未选择相关参数。', '输入错误');
    else
       assignin('base', 'deep', deep_);
       assignin('base', 'fast', fast_);
       assignin('base', 'speed', speed_);
       assignin('base', 'tool_num', tool_num_);
       assignin('base', 'Pway', Pway_-1);
       assignin('base','duidaox',duidaox_);
       assignin('base','duidaoy',duidaoy_);
       assignin('base','duidaoz',duidaoz_);
       assignin('base','direction',direction-1);
       %转换刀补成g代码
       assignin('base', 'conpensation_way', compensation_way_+39);
    end

% --- Executes during object deletion, before destroying properties.
function CNCcodetext_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to CNCcodetext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in Gcodebox.
function Gcodebox_Callback(hObject, eventdata, handles)
% hObject    handle to Gcodebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Gcodebox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Gcodebox


% --- Executes during object creation, after setting all properties.
function Gcodebox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gcodebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function tool_path_figurebox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tool_path_figurebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate tool_path_figurebox



function length_inter_Callback(hObject, eventdata, handles)
% hObject    handle to length_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of length_inter as text
%        str2double(get(hObject,'String')) returns contents of length_inter as a double


% --- Executes during object creation, after setting all properties.
function length_inter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to length_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function width_inter_Callback(hObject, eventdata, handles)
% hObject    handle to width_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of width_inter as text
%        str2double(get(hObject,'String')) returns contents of width_inter as a double


% --- Executes during object creation, after setting all properties.
function width_inter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to width_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function height_inter_Callback(hObject, eventdata, handles)
% hObject    handle to height_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of height_inter as text
%        str2double(get(hObject,'String')) returns contents of height_inter as a double


% --- Executes during object creation, after setting all properties.
function height_inter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to height_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in compensation_inter.
function compensation_inter_Callback(hObject, eventdata, handles)
% hObject    handle to compensation_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns compensation_inter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from compensation_inter


% --- Executes during object creation, after setting all properties.
function compensation_inter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to compensation_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in tool_choosing.
function tool_choosing_Callback(hObject, eventdata, handles)
% hObject    handle to tool_choosing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tool_choosing contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tool_choosing


% --- Executes during object creation, after setting all properties.
function tool_choosing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tool_choosing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 % 读取生成的走刀路径图像并显示到软件上
imageData = imread('C:\Users\Administrator\Desktop\DXFtool_v1.0\DXFtool_v1.0\plot_image.png'); 
imshow(imageData, 'Parent', handles.tool_path_figurebox); 


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 dxf=evalin('base','dxf');
 entities = dxf.entities;
 entities = BFS(entities);
 fixOffsetPath2(entities);
 imageData3 = imread('C:\Users\Administrator\Desktop\DXFtool_v1.0\DXFtool_v1.0\plot_image_daobu.png'); 
imshow(imageData3, 'Parent', handles.compensation_figurebox); 

function Gcenter_x_inter_Callback(hObject, eventdata, handles)
% hObject    handle to Gcenter_x_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Gcenter_x_inter as text
%        str2double(get(hObject,'String')) returns contents of Gcenter_x_inter as a double


% --- Executes during object creation, after setting all properties.
function Gcenter_x_inter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gcenter_x_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Gcenter_y_inter_Callback(hObject, eventdata, handles)
% hObject    handle to Gcenter_y_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Gcenter_y_inter as text
%        str2double(get(hObject,'String')) returns contents of Gcenter_y_inter as a double


% --- Executes during object creation, after setting all properties.
function Gcenter_y_inter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gcenter_y_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Gcenter_z_inter_Callback(hObject, eventdata, handles)
% hObject    handle to Gcenter_z_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Gcenter_z_inter as text
%        str2double(get(hObject,'String')) returns contents of Gcenter_z_inter as a double


% --- Executes during object creation, after setting all properties.
function Gcenter_z_inter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gcenter_z_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_botton2.
function save_botton2_Callback(hObject, eventdata, handles)
% hObject    handle to save_botton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%获取模具长度
length_ = get(handles.length_inter,'String');
%获取模具宽度
width_ = get(handles.width_inter, 'String');
% 获取模具高度
height_ = get(handles.height_inter, 'String');   
% 获取几何中心x坐标
Gcenter_x_= get(handles.Gcenter_x_inter, 'String');
% 获取几何中心y坐标
Gcenter_y_= get(handles.Gcenter_y_inter, 'String');
% 获取几何中心z坐标
Gcenter_z_= get(handles.Gcenter_z_inter, 'String');
   
% 存储到变量中
    length_ = str2double(length_);
    width_ = str2double(width_);
    height_ = str2double(height_);
    Gcenter_x_ = str2double(Gcenter_x_);
    Gcenter_y_ = str2double(Gcenter_y_);
    Gcenter_z_= str2double(Gcenter_z_);
    % 判断输入的是否是数字
    if (isnan(length_) || isnan(width_) || isnan(height_)||isnan(Gcenter_x_)||isnan(Gcenter_y_)||isnan(Gcenter_z_))
        % 如果输入不是有效的数字，弹出警告框
        errordlg('没有输入相关参数或输入有误。', '输入错误');
    else
       assignin('base', 'length', length_);
       assignin('base', 'width',width_);
       assignin('base', 'height',height_);
       assignin('base', 'Gcenter_x',Gcenter_x_);
       assignin('base', 'Gcenter_y',Gcenter_y_);
       assignin('base', 'Gcenter_z',Gcenter_z_);
    end
    
% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes6);

%% 调用函数显示刀具行进动画
create_tool_path_animation_3D('C:\Users\Administrator\Desktop\DXFtool_v1.0\DXFtool_v1.0\output.txt');


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function axes6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes6
%旋转功能
%rotate3d(hObject,'on');
%缩放功能
%zoom(hObject,'on');


% --- Executes on selection change in Pway_inter.
function Pway_inter_Callback(hObject, eventdata, handles)
% hObject    handle to Pway_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Pway_inter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Pway_inter


% --- Executes during object creation, after setting all properties.
function Pway_inter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pway_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
rotate3d(handles.axes6,'on');
zoom(handles.axes6,'off');
  if get(hObject, 'Value') == 1
            set(handles.radiobutton2, 'Value', 0);
        end

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
    if get(hObject, 'Value') == 1
            set(handles.radiobutton1, 'Value', 0);
        end
rotate3d(handles.axes6,'off');
zoom(handles.axes6,'on');


% --- Executes during object creation, after setting all properties.
function radiobutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function duidaox_inter_Callback(hObject, eventdata, handles)
% hObject    handle to duidaox_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of duidaox_inter as text
%        str2double(get(hObject,'String')) returns contents of duidaox_inter as a double


% --- Executes during object creation, after setting all properties.
function duidaox_inter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to duidaox_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function duidaoy_inter_Callback(hObject, eventdata, handles)
% hObject    handle to duidaoy_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of duidaoy_inter as text
%        str2double(get(hObject,'String')) returns contents of duidaoy_inter as a double


% --- Executes during object creation, after setting all properties.
function duidaoy_inter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to duidaoy_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function duidaoz_inter_Callback(hObject, eventdata, handles)
% hObject    handle to duidaoz_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of duidaoz_inter as text
%        str2double(get(hObject,'String')) returns contents of duidaoz_inter as a double


% --- Executes during object creation, after setting all properties.
function duidaoz_inter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to duidaoz_inter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
