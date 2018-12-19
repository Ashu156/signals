function Visualizor()
% Visualize a signals network
%  Could read in an experiment definition and plot a 'node' for each variable and 
%  connect them with lines annotated with their transfer function.  
%  TODO start with row of input nodes at level 0 at the top of the figure (inputs,
%  events, etc.) along with buttons for adding, deleting and connecting nodes.  
%  Each new node is added below the last (iterate level).  Could simultaneously 
%  write to expDef file.  Here signal Name would translate to variable name.
%  TODO implement as class
%  TODO option of adding real nodes at the same time as graphing them
f = figure;
net = gca();
c = uicontextmenu(f);
% Create a new component and assign the uicontextmenu to it
b = uicontrol(f,'UIContextMenu',c);
% Create a child menu for the uicontextmenu
m = uimenu('Parent',c,'Label','Add Node','MenuSelectedFcn', @(~,~)addNode);

level = 0;

inputNodes = [];
nodes = [];
eventNodes = [];

inputNodes(1) = addNode('t');

    function node = addNode(name, next)
        if nargin > 1; level = next; end
        node = scatter(net, 1, level, 4000, 'o', 'LineWidth', 2, 'MarkerEdgeColor', 'r');
        node.CreateFcn = '';
        node.DeleteFcn = '@deleteNode';
        node.DisplayName = name;
        node.PickableParts = 'all';
    end

    function node = deleteNode(src, evt)
        % pass
    end
end
