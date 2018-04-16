function InteractiveFigures
%Demo of figure callbacks for interactive simulations.
% Integrates a draggable mass,spring,damper system while allowing you to
% interact with it using mouse or keyboard.
%
% Things to try:
% 1. Click and drag to move the point.
% 2. Press 'r' to move back to center.
% 3. press up/down arrow keys to change mass and point size
% 4. press left/right arrow keys to change spring stiffness and point
% color.


%More info on figure callbacks:
%http://www.mathworks.com/help/matlab/ref/figure-properties.html
%M.Sheen


p.behavior = 2; %Behavior 1 -- force is set when the mouse is moved. Behavior 2 -- spring setpoint is created when the mouse is moved.


%Figure handle -- Key point! Must set callback functions for
%mouse,keyboard,etc.
f = figure;
set(f,'WindowButtonMotionFcn','','WindowButtonDownFcn',@ClickDown,'WindowButtonUpFcn',@ClickUp,'WindowKeyPressFcn',@KeyPress,'CloseRequestFcn',@KillAll);
p.lim = 5;
aH = axes('Xlim',[-p.lim p.lim],'Ylim', [-p.lim p.lim]);



p.f = f; %put the figure handle inside the structure being passed to the RHS function
f.UserData.F = [0 0]; %Figure handles let you include a UserData field. This allows the mouse callbacks to set the force and the RHS to see it without globals.
f.UserData.k = 10; %Mouse spring constant
f.UserData.m = 1;
f.UserData.reset = false; %Reset flag
f.UserData.mouseX = 1;
f.UserData.mouseY = 1;
p.c = 15; %Mouse spring damper (haha)

f.UserData.integrate = true; %This lets the callbacks stop integration (prevents errors when closing the window).
init = [0,0,0,0]'; %Initial dot state - x,y,xdot,ydot
h = plot(init(1),init(2),'.','MarkerSize',50); %Put a point on a plot and keep the figure handle.


%%%%%% RK4 in real time %%%%%%%%
z1 = init;
told = 0; %start time
tic
while (f.UserData.integrate) %As long as i don't close the figure, keep integrating.
    if f.UserData.reset %Check if the reset command has been called (r keystroke)
        z1 = init;
        f.UserData.reset = false;
    end
    
    tnew = toc;
    dt = tnew - told;
    
    k1 = dynamics(tnew,z1,p);
    k2 = dynamics(tnew,z1+dt/2*k1,p);
    k3 = dynamics(tnew,z1+dt/2*k2,p);
    k4 = dynamics(tnew,z1+dt*k3,p);
    
    z2 = z1 + dt/6*(k1 + 2*k2 + 2*k3 + k4);
    z1 = z2;
    
    set(h,'xData',z1(1));
    set(h,'yData',z1(2));
    axis([-5 5 -5 5]);
    told = tnew;
    pause(0.001);
end
delete(f); %When integration stops, close the figure.



%%% RHS function -- mass,spring,damper %%%
    function zdot = dynamics(t,z,p)
        
        xdot = z(3);
        ydot = z(4);
        if p.behavior ==2
            p.f.UserData.F = p.f.UserData.k*[(p.f.UserData.mouseX-z(1)), (p.f.UserData.mouseY-z(2))];
        end
        xdotdot = p.f.UserData.F(1)/p.f.UserData.m-p.c*xdot;
        ydotdot = p.f.UserData.F(2)/p.f.UserData.m-p.c*ydot;
        
        
        zdot = [xdot ydot xdotdot ydotdot]';
    end

%%% Mouse force update calc %%%
    function mouseUpdate(fig,event)
        ax = fig.Children; %src is the figure handle. Its child is the axes handle.
        pt = ax.Children; %The axis handle's child is the line (or point) being plotted.
        
        xcurrent = pt.XData; %Get the current location of the point.
        ycurrent = pt.YData;
        mousePos = ax.CurrentPoint; %Get the current location of the mouse
        
        fig.UserData.mouseX = mousePos(1,1);
        fig.UserData.mouseY = mousePos(1,2);
        fig.UserData.F = fig.UserData.k*[(mousePos(1,1)-xcurrent), (mousePos(1,2)-ycurrent)]; %Make a spring force.
    end

%%%%%%%%%%%% MOUSE CALLBACKS %%%%%%%%%%%%
% Get called automatically based on action.
% Each callback gets 2 inputs: the event source (i.e. the figure handle)
% and the event (e.g. rightclick, leftarrow...).

%Mouse position callback
    function MousePos(fig,event)
        mouseUpdate(fig,event);
    end

%Mouse click callback - press.
    function ClickDown(fig,event)
        mouseUpdate(fig,event);
        fig.WindowButtonMotionFcn = @MousePos; %Set the figure's mouse position callback (i.e. turn it on).

    end

%Mouse click callback - release.
    function ClickUp(fig,event)
        mouseUpdate(fig,event);
        fig.WindowButtonMotionFcn = ''; %When the mouse is released, set the figure's mouse callback to '' (i.e. turn it off)
    end

%%%%%%%%%%% KEYBOARD CALLBACKS %%%%%%%%%%%
    function KeyPress(fig,event)
        ax = fig.Children; %Child is the axis handle
        pt = ax.Children; %The axis handle's child is the line (or point) being plotted.
        colormax = 400; %This is just for changing the point color based on key presses
        key = event.Key;
        if strcmp(key,'uparrow') %Up arrow increases point mass and size
            fig.UserData.m = fig.UserData.m*1.2; % Increase the mass parameter
            pt.MarkerSize = pt.MarkerSize*1.5; % Increase the marker size
        elseif strcmp(key,'downarrow')
            fig.UserData.m = fig.UserData.m*1/1.2; %Change mass
            pt.MarkerSize = pt.MarkerSize*2/3;
        elseif strcmp(key,'rightarrow') %Right arrow increases stiffness and changes point color
            fig.UserData.k = fig.UserData.k*1.5;
            pt.Color = interp1(linspace(0,colormax,size(jet,1)),jet,fig.UserData.k,'linear',0.5);
        elseif strcmp(key,'leftarrow')
            fig.UserData.k = fig.UserData.k*2/3;
            pt.Color = interp1(linspace(0,colormax,size(jet,1)),jet,fig.UserData.k,'linear',0.5);
        elseif strcmp(key,'r') %r key sets a flag which causes integration to bring the point back to center.
            fig.UserData.reset = true;
        end
    end

%%%%%%%%%%% OTHER CALLBACKS %%%%%%%%%%%
    function KillAll(src,event) %This is the callback for when the figure is closed.
        src.UserData.integrate = false; %Tell the integration loop to stop trying.
        set(src,'WindowButtonMotionFcn',''); %Clear all the callbacks to prevent errors.
        set(src,'WindowButtonDownFcn','');
        set(src,'WindowButtonUpFcn','');
    end


end