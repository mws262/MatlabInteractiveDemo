function MouseInteraction_DotTracking
% Click and drag mouse to move the dot. Obeys spring-mass-damper dynamics.
% Example for user interaction for MAE 5230.
%
% Matt Sheen, 2018

close all;

ballState = [0,0,0,0]; % x, y, xdot, ydot
setPt = [1,1]; % Tracking point, i.e. where the spring-mass-damper is connected
step = 0.01; % Timestep

% Physical parameters
c = 1;
m = 1;
k = 5;

% make figure, assign callbacks (actions to take when user input happens).
fig = figure;
fig.WindowButtonDownFcn = @pressCallback;
fig.WindowButtonUpFcn = @releaseCallback;
ax = axes;
pl = plot(ballState(1), ballState(2),'.','MarkerSize',30);
axis([-2,2,-2,2]);
daspect([1,1,1]);

% Integration/animation loop
while ishandle(fig) % Stop the loop when figure is closed.
    % Euler integration.
    stDot = dynamics(ballState);
    ballState = ballState + stDot*step;
    pl.XData = ballState(1);
    pl.YData = ballState(2);
    pause(step);
end

% Called when mouse button goes down.
    function pressCallback(src,data)
        setPt = [ax.CurrentPoint(1,1),ax.CurrentPoint(1,2)];
        fig.WindowButtonMotionFcn = @dragCallback;
    end

% Called when mouse button moves.
    function dragCallback(src,data)
        setPt = [ax.CurrentPoint(1,1),ax.CurrentPoint(1,2)];
    end

% Called when mouse button released
    function releaseCallback(src,data)
       fig.WindowButtonMotionFcn = ''; 
    end

% Spring-mass-damper dynamics for a point mass.
    function zdot = dynamics(z)
        x = z(1);
        y = z(2);
        
        xdot = z(3);
        ydot = z(4);
        Fx = k*(setPt(1) - x) - c*(xdot);
        Fy = k*(setPt(2) - y) - c*(ydot);
        
        xdd = Fx/m;
        ydd = Fy/m;
        zdot = [xdot,ydot,xdd,ydd];
    end
end