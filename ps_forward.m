function varargout = ps_forward(varargin)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
% PS_FORWARD M-file for ps_forward.fig
%      PS_FORWARD, by itself, creates a new PS_FORWARD or raises the existing
%      singleton*.
%
%      H = PS_FORWARD returns the handle to a new PS_FORWARD or the handle to
%      the existing singleton*.
%
%      PS_FORWARD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PS_FORWARD.M with the given input arguments.
%
%      PS_FORWARD('Property','Value',...) creates a new PS_FORWARD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ps_forward_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ps_forward_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ps_forward

% Last Modified by GUIDE v2.5 15-Jan-2011 23:11:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ps_forward_OpeningFcn, ...
                   'gui_OutputFcn',  @ps_forward_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
%
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ps_forward is made visible.
function ps_forward_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ps_forward (see VARARGIN)

% Choose default command line output for ps_forward
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ps_forward wait for user response (see UIRESUME)
% uiwait(handles.fig_ps_forward);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fpara format
% Gfpara, fpara global
% Ginfo,  the info of all figures
global Gfpara ginfo switch_update Cfpara fig3dID
Gfpara        = zeros(10);
switch_update = 0;
Cfpara        = Gfpara;
fig3dID       = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ps_forword_init;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Outputs from this function are returned to the command line.
function varargout = ps_forward_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function button_Callback(hObject, eventdata, handles)
% hObject    handle to edt_inp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global Gfpara ginfo Cfpara fig3dID
%
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
tagname = get(hObject,'tag');
%disp(tagname);
switch tagname 
    case 'list_format'
        ps_forword_init;
    case 'list_fault_index'
        ps_forword_init;
        %ginfo.faultno
        ps_forword_current;
    case 'list_para_index'
        ps_forword_init;
        %ginfo.para.value{ginfo.para.no}
        ps_forword_current;
    case 'but_div'
        ps_forword_init;
        set(ginfo.currentparaid,'String',...
            num2str(ginfo.currentpara-ginfo.step));
        ps_forword_init;
        ps_forword_fig3d;
    case 'but_plus'
        ps_forword_init;
        set(ginfo.currentparaid,'String',...
            num2str(ginfo.currentpara+ginfo.step));
        ps_forword_init;
        ps_forword_fig3d;
    case 'but_psoksar'
        [filename,filepathname,fileindex] = uigetfile('*.*');
        %
        if fileindex~=0
            set(ginfo.psoksarid,'String',fullfile(filepathname,filename));
            %
            ps_forword_init;
            ps_forword_read;
        end
    case 'but_inp'
        %disp('inp');
    case 'but_read'
        ps_forword_init;
        ps_forword_read;
    case 'but_fig3d'
        ps_forword_fig3d;
end
ps_forword_update;
%Cfpara(ginfo.faultno,ginfo.para.no) = ginfo.currentpara;
