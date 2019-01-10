classdef FieldPanel < handle
  %UNTITLED Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    MinCtrlWidth = 20
    MaxCtrlWidth = 140
    Margin = 4
    RowSpacing = 1
    ColSpacing = 3
    UI
    ConditionTable
    ContextMenu
  end
  
  properties (Access = protected)
    MinRowHeight
    Listener
    Labels
    Controls
    LabelWidths
  end
  
  methods
    function obj = FieldPanel(f,varargin)
      obj.UI = uipanel('Parent', f, 'BorderType', 'none',...
          'BackgroundColor', 'white', 'Position', [0 0 0.5 1]);
      obj.UI(2) = uipanel('Parent', f, 'BorderType', 'none',...
          'BackgroundColor', 'black', 'Position',  [0.5 0 0.5 1]);
      obj.Listener = event.listener(obj.UI, 'SizeChanged', @obj.onResize);
      c = uicontextmenu;
      [obj.UI.UIContextMenu] = deal(c);
      % Create a child menu for the uicontextmenu
      obj.ContextMenu = uimenu(c, 'Label','Make Coditional');
      obj.ConditionTable = uitable('Parent', obj.UI(2),...
        'FontName', 'Consolas',...
        'RowName', [],...
        'RearrangeableColumns', true,...
        'Units', 'normalized',...
        'Position',[0 0 1 1],...
        'CellEditCallback', @nop,...%@obj.cellEditCallback,...
        'CellSelectionCallback', @nop);%@obj.cellSelectionCallback);
    end

    function [label, ctrl] = addField(obj, name, ctrl)
      label = uicontrol('Parent', obj.UI(1), 'Style', 'text', 'String', name,...
        'HorizontalAlignment', 'left', 'BackgroundColor', 'white');
      callback = @(~,~)onEdit(obj, name);
      if nargin < 3
        ctrl = uicontrol('Parent', obj.UI(1), 'Style', 'edit', 'HorizontalAlignment', 'left');
      end
      set(ctrl, 'Callback', callback);
      obj.Labels = [obj.Labels; label];
      obj.Controls = [obj.Controls; ctrl];
    end
    
    function delete(obj)
      disp('delete called');
      delete(obj.UI);
    end
    
    function onEdit(obj, id)
      disp(id);
      changed = strcmp(id{:},[obj.Labels.String]);
      obj.Labels(changed).ForegroundColor = [1 0 0];
    end
    
    function onResize(obj, ~, ~)
      if isempty(obj.LabelWidths)
        ext = reshape([obj.Labels.Extent], 4, [])';
        obj.LabelWidths = ext(:,3);
        l = uicontrol('Parent', obj.UI(1), 'Style', 'edit', 'String', 'something');
        obj.MinRowHeight = l.Extent(4);
        delete(l);
      end
      
      %%% resize condition table
      w = numel(obj.ConditionTable.ColumnName);
      if w > 5; w = 0.5; else; w = 0.1 * w; end
      obj.UI(2).Position = [1-w 0 w 1];
      obj.UI(1).Position = [0 0 1-w 1];
      
      %%% general coordinates
      pos = getpixelposition(obj.UI(1));
      borderwidth = obj.Margin;
      bounds = [pos(3) pos(4)] - 2*borderwidth;
      n = numel(obj.Labels);
      vspace = obj.RowSpacing;
      hspace = obj.ColSpacing;
      rowHeight = obj.MinRowHeight + 2*vspace;
      rowsPerCol = floor(bounds(2)/rowHeight);
      cols = ceil((1:n)/rowsPerCol)';
      ncols = cols(end);
      rows = mod(0:n - 1, rowsPerCol)' + 1;
      labelColWidth = max(obj.LabelWidths) + 2*hspace;
      ctrlWidthAvail = bounds(1)/ncols - labelColWidth;
      ctrlColWidth = max(obj.MinCtrlWidth, min(ctrlWidthAvail, obj.MaxCtrlWidth));
      fullColWidth = labelColWidth + ctrlColWidth;
      
      %%% coordinates of labels
      by = bounds(2) - rows*rowHeight + vspace + 1 + borderwidth;
      labelPos = [vspace + (cols - 1)*fullColWidth + 1 + borderwidth...
        by...
        obj.LabelWidths...
        repmat(rowHeight - 2*vspace, n, 1)];
    
      %%% coordinates of edits
      editPos = [labelColWidth + hspace + (cols - 1)*fullColWidth + 1 + borderwidth ...
        by...
        repmat(ctrlColWidth - 2*hspace, n, 1)...
        repmat(rowHeight - 2*vspace, n, 1)];
      set(obj.Labels, {'Position'}, num2cell(labelPos, 2));
      set(obj.Controls, {'Position'}, num2cell(editPos, 2));
    end
  end
  
end

