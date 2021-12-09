function out = pvaGet(channel, varargin)
    aidainit
    if ( ~empty(varargin) )
        out = edu.stanford.slac.aida.client.AidaPvaClientUtils.pvaGet(channel, varargin);
    else
        out = edu.stanford.slac.aida.client.AidaPvaClientUtils.pvaGet(channel);
    end
end
