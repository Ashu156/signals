classdef ParamEditor < handle
  %UNTITLED2 Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    UI
    Parameters
  end
  
  methods
    function obj = ParamEditor(f)
        if nargin == 0; f = figure; end
      obj.UI = ui.FieldPanel(f);
    end
    
    function buildUI(obj, pars)
      obj.Parameters = pars;
      c = obj.UI;
      names = pars.GlobalNames;
      for nm = names'
        [~, ctrl] = addField(c, nm);
        ctrl.String = obj.paramValue2Control(pars.Struct.(nm{:}));
      end
    end
  end
  
  methods
    function data = paramValue2Control(obj, data)
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
  end
end

