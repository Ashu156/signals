classdef ParamEditor < handle
  %UNTITLED2 Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    GlobalUI
    ConditionalUI
    Parameters
  end
  
  properties
  end
  
  events
    Changed
  end
  
  methods
    function obj = ParamEditor(pars, f)
      if nargin == 0; pars = []; end
      if nargin < 2
        f = figure('Name', 'Parameters', 'NumberTitle', 'off',...
          'Toolbar', 'none', 'Menubar', 'none');
      end
      obj.GlobalUI = ui.FieldPanel(f, obj);
      obj.ConditionalUI = ui.ConditionPanel(f, obj);
      obj.buildUI(pars);
    end
    
    function buildUI(obj, pars)
      obj.Parameters = pars;
      clear(obj.GlobalUI);
      clear(obj.ConditionalUI);
      c = obj.GlobalUI;
      names = pars.GlobalNames;
      for nm = names'
        if islogical(pars.Struct.(nm{:})) % If parameter is logical, make checkbox
          ctrl = uicontrol('Parent', c.UIPanel, 'Style', 'checkbox', ...
            'Value', pars.Struct.(nm{:}), 'BackgroundColor', 'white');
          addField(c, nm, ctrl);
        else
          [~, ctrl] = addField(c, nm);
          ctrl.String = obj.paramValue2Control(pars.Struct.(nm{:}));
        end
      end
      obj.fillConditionTable();
      obj.GlobalUI.onResize();
    end
    
    function fillConditionTable(obj)
      % Build the condition table
      titles = obj.Parameters.TrialSpecificNames;
      [~, trialParams] = obj.Parameters.assortForExperiment;
      data = reshape(struct2cell(trialParams), numel(titles), [])';
      data = mapToCell(@(e) obj.paramValue2Control(e), data);
      set(obj.ConditionalUI.ConditionTable, 'ColumnName', titles, 'Data', data,...
        'ColumnEditable', true(1, numel(titles)));
    end
    
    function newValue = update(obj, name, value, row)
      if nargin < 4; row = 1; end
      currValue = obj.Parameters.Struct.(name)(:,row);
      if iscell(currValue)
        % cell holders are allowed to be different types of value
        newValue = obj.controlValue2Param(currValue{1}, value, true);
        obj.Parameters.Struct.(name){:,row} = newValue;
      else
        newValue = obj.controlValue2Param(currValue, value);
        obj.Parameters.Struct.(name)(:,row) = newValue;
      end
      notify(obj, 'Changed');
    end
    
    function globaliseParamAtCell(obj, name, row)
      % Make parameter 'name' a global parameter and set it's value to be
      % that of the specified row.
      %
      % See also EXP.PARAMETERS/MAKEGLOBAL, UI.CONDITIONPANEL/MAKEGLOBAL
      value = obj.Parameters.Struct.(name)(:,row);
      obj.Parameters.makeGlobal(name, value);
      % Refresh the table of conditions
      obj.fillConditionTable;
      % Add new global parameter to field panel
      if islogical(value) % If parameter is logical, make checkbox
        ctrl = uicontrol('Parent', obj.GlobalUI.UIPanel, 'Style', 'checkbox', ...
          'Value', value, 'BackgroundColor', 'white');
        addField(obj.GlobalUI, name, ctrl);
      else
        [~, ctrl] = addField(obj.GlobalUI, name);
        ctrl.String = obj.paramValue2Control(value);
      end
      obj.GlobalUI.onResize();
    end
  
%     function cellSelectionCallback(obj, ~, eventData)
%       obj.SelectedCells = eventData.Indices;
%       if size(eventData.Indices, 1) > 0
%         %cells selected, enable buttons
%         set(obj.MakeGlobalButton, 'Enable', 'on');
%         set(obj.DeleteConditionButton, 'Enable', 'on');
%         set(obj.SetValuesButton, 'Enable', 'on');
%       else
%         %nothing selected, disable buttons
%         set(obj.MakeGlobalButton, 'Enable', 'off');
%         set(obj.DeleteConditionButton, 'Enable', 'off');
%         set(obj.SetValuesButton, 'Enable', 'off');
%       end
%     end
    
  end
  
  methods
    
  end
  methods (Static)
    function data = paramValue2Control(data)
      % convert from parameter value to control value, i.e. a value class
      % that can be easily displayed and edited by the user.  Everything
      % except logicals are converted to charecter arrays.
      switch class(data)
        case 'function_handle'
          % convert a function handle to it's string name
          data = func2str(data);
        case 'logical'
          data = data ~= 0; % If logical do nothing, basically.
        case 'string'
          data = char(data); % Strings not allowed in condition table data
        otherwise
          if isnumeric(data)
            % format numeric types as string number list
            strlist = mapToCell(@num2str, data);
            data = strJoin(strlist, ', ');
          elseif iscellstr(data)
            data = strJoin(data, ', ');
          end
      end
      % all other data types stay as they are
    end
    
    function data = controlValue2Param(currParam, data, allowTypeChange)
      % Convert the values displayed in the UI ('control values') to
      % parameter values.  String representations of numrical arrays and
      % functions are converted back to their 'native' classes.
      if nargin < 4
        allowTypeChange = false;
      end
      switch class(currParam)
        case 'function_handle'
          data = str2func(data);
        case 'logical'
          data = data ~= 0;
        case 'char'
          % do nothing - strings stay as strings
        otherwise
          if isnumeric(currParam)
            % parse string as numeric vector
            try
              C = textscan(data, '%f',...
                'ReturnOnError', false,...
                'delimiter', {' ', ','}, 'MultipleDelimsAsOne', 1);
              data = C{1};
            catch ex
              % if a type change is allowed, then a numeric can become a
              % string, otherwise rethrow the parse error
              if ~allowTypeChange
                rethrow(ex);
              end
            end
          elseif iscellstr(currParam)
            C = textscan(data, '%s',...
                'ReturnOnError', false,...
                'delimiter', {' ', ','}, 'MultipleDelimsAsOne', 1);
            data = C{1};%deblank(num2cell(data, 2));
          else
            error('Cannot update unimplemented type ''%s''', class(currParam));
          end
      end
    end

  end
end

