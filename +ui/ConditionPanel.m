classdef ConditionPanel < handle
  %UNTITLED Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    ConditionTable
    MinCtrlWidth = 40
    MaxCtrlWidth = 140
    Margin = 4
    RowSpacing = 1
    ColSpacing = 3
    UIPanel
    ContextMenu
  end
  
  properties %(Access = protected)
    ParamEditor
    MinRowHeight
    Listener
    Labels
    Controls
    LabelWidths
    SelectedCells %[row, column;...] of each selected cell
  end
  
  methods
    function obj = ConditionPanel(f, ParamEditor, varargin)
      obj.ParamEditor = ParamEditor;
      obj.UIPanel = uipanel('Parent', f, 'BorderType', 'none',...
          'BackgroundColor', 'black', 'Position',  [0.5 0 0.5 1]);
      obj.Listener = event.listener(obj.UIPanel, 'SizeChanged', @obj.onResize);
      c = uicontextmenu;
      obj.UIPanel.UIContextMenu = c;
      % Create a child menu for the uicontextmenu
      obj.ContextMenu = uimenu(c, 'Label', 'Make Global', 'Callback', @(~,~)obj.makeGlobal);
      obj.ConditionTable = uitable('Parent', obj.UIPanel,...
        'FontName', 'Consolas',...
        'RowName', [],...
        'RearrangeableColumns', true,...
        'Units', 'normalized',...
        'Position',[0 0 1 1],...
        'UIContextMenu', c,...
        'CellEditCallback', @obj.onEdit,...
        'CellSelectionCallback', @obj.onSelect);
    end

    function onEdit(obj, src, eventData)
      disp('updating table cell');
      row = eventData.Indices(1);
      col = eventData.Indices(2);
      paramName = obj.ConditionTable.ColumnName{col};
      newValue = obj.ParamEditor.update(paramName, eventData.NewData, row);
      reformed = obj.ParamEditor.paramValue2Control(newValue);
      % If successful update the cell with default formatting
      data = get(src, 'Data');
      if iscell(reformed)
        % The reformed data type is a cell, this should be a one element
        % wrapping cell
        if numel(reformed) == 1
          reformed = reformed{1};
        else
          error('Cannot handle data reformatted data type');
        end        
      end
      data{row,col} = reformed;      
      set(src, 'Data', data);
    end
    
    function clear(obj)
      set(obj.ConditionTable, 'ColumnName', [], ...
        'Data', [], 'ColumnEditable', false);
    end
    
    function delete(obj)
      disp('delete called');
      delete(obj.UIPanel);
    end
    
    function onResize(obj, ~, ~)
      if isempty(obj.ConditionTable.Data)
        return
      end
      %%% resize condition table
      w = numel(obj.ConditionTable.ColumnName);
%       nCols = max(cols);
%       globalWidth = (fullColWidth * nCols) + borderwidth;
%       if w > 5; w = 0.5; else; w = 0.1 * w; end
%       obj.UIPanel.Position = [1-w 0 w 1];
    end
    
    function onSelect(obj, ~, eventData)
      obj.SelectedCells = eventData.Indices;
%       if size(eventData.Indices, 1) > 0
        %cells selected, enable buttons
%         obj.ContextMenu.Visible = 'off';
%       else
        %nothing selected, disable buttons
%         set(obj.MakeGlobalButton, 'Enable', 'off');
%         set(obj.DeleteConditionButton, 'Enable', 'off');
%         set(obj.SetValuesButton, 'Enable', 'off');
%       end
    end

    function makeGlobal(obj)
      [cols, iu] = unique(obj.SelectedCells(:,2));
      names = obj.ConditionTable.ColumnName(cols);
      rows = num2cell(obj.SelectedCells(iu,1)); %get rows of unique selected cols
      PE = obj.ParamEditor;
      cellfun(@PE.globaliseParamAtCell, names, rows);
    end
    
  end
  
end