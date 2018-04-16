function MouseInteraction_Lasers
% Makes a laser turret that shoots when you click different points on the
% plot. Just a demo for mouse interaction made for MAE 5730.
%
% Matt Sheen, 2018

close all;

% Make figure and axes and plot graphics objects.
fig = figure;
ax = axes;
pl = plot3([0,0],[0,0],[0,1], 'LineWidth', 5);
ax.ZLim = [0 6]; % Change the 3D axis limits.
ax.YLim = [-5 5];
ax.XLim = [-5 5];

daspect([1,1,1]); % Make sure no axis is stretched more than others.
grid on

% KEY LINE: Assign the function which gets called when the mouse button is
% pressed down.
fig.WindowButtonDownFcn = @mouseCallback;

%% Animation loop
hold on;
laserVec = {};
step = 0.02;
% Animation loop
while ishandle(fig) % Keeps going until someone exits the figure window.
    for i = 1:length(laserVec) % Iterate over all laser shots.
        
        thisBullet = laserVec{i}{2}; % Plot for this laser shot.
        thisShootVec = laserVec{i}{1}; % Vector of its direction.
        
        % Update the plot by moving the laser shot from its current
        % location slightly in the direction of the shootVec.
        thisBullet.XData = thisShootVec(1) * step + thisBullet.XData;
        thisBullet.YData = thisShootVec(2) * step + thisBullet.YData;
        thisBullet.ZData = thisShootVec(3) * step + thisBullet.ZData;
    end
    pause(0.02);
end


%% KEY LINES: This function gets called when the mouse button is pressed down.
    function mouseCallback(src, data) % src tells us what graphics object triggered the event. data tells us more info about the event. Both are structures.
        clickVec = ax.CurrentPoint; % CurrentPoint is the location of the mouse in the axes.
                                    % CurrentPoint contains two points ---
                                    % these define a ray going from the
                                    % view camera to the click projection
                                    % on the axis. In 2D, you can basically
                                    % use either.
       
        % If we had done fig.CurrentPoint we would have gotten mouse location in 
        % PIXEL coordinates in the figure window.
        
        
        % Make {shootVector, plotforshot}, i.e.
        % Define a ray going from the "laser turret" to the click location.
        % Also create a new plot3 with a single point starting at the laser
        % turret. Smoosh these in a cell array for convenience.
        laserVec{end + 1} = {clickVec(2,:) - [pl.XData(end), pl.YData(end), pl.ZData(end)],  plot3(pl.XData(end), pl.YData(end), pl.ZData(end), '.', 'MarkerSize', 20)};
    end
end