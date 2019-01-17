classdef OriginSignal < sig.node.Signal
  % sig.node.OriginSignal: signal class upon which all other signals depend
  %   Origin signals are the input nodes to the running reactive network
  %   during a *signals* experiment. They serve as signals which
  %   all other signals are dependent on, and can be created in the
  %   reactive network. They are updated directly via the 'post' method.
  
  properties (SetAccess = private, Transient)
    ActiveTimers
  end
  
  methods
    function this = OriginSignal(node)
      this = this@sig.node.Signal(node);
    end

    function post(this, v)
      affectedIdxs = submit(this.Node.NetId, this.Node.Id, v);
%       changed = applyNodes(this.Node.NetId, affectedIdxs);
      applyNodes(this.Node.NetId, affectedIdxs);
    end

    function delayedPost(this, value, delay)
      t = GetSecs;
      if nargin < 3
        [value, delay] = value{:};
      end
      this.Node.Net.Schedule(end+1) = struct('nodeid', this.Node.Id, 'value', value, 'when', t + delay);
%       tmr = timer('TimerFcn', @tmrfn, 'StartDelay', delay - 3e-3); %NB: hacky lag correction
%       this.ActiveTimers = [this.ActiveTimers tmr];
%       start(tmr);
      
%       function tmrfn(~,~)
%         global inPost
%         
%         if inPost
%           disp('***** starting delay post while normal post in progress **** ');
%         end
% %         assert(~inPost, 'starting delay post while normal post in progress');
%         post(this, value);
%         idx = this.ActiveTimers == tmr;
%         if numel(this.ActiveTimers) == 1
%           this.ActiveTimers = [];
%         else
%           this.ActiveTimers(idx) = [];
%         end
%         stop(tmr);
%         delete(tmr);
%       end
    end
    
    function cancelPending(this)
      if ~isempty(this.ActiveTimers)
        stop(this.ActiveTimers);
        delete(this.ActiveTimers);
        this.ActiveTimers = [];
      end
    end
  end
end

