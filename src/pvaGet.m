function out = pvaGet(channel, varargin)
    aidainit
    if ( ~empty(varargin) )
        out = edu.stanford.slac.aida.client.AidaPvaClientUtils.pvaGet(channel, varargin(1));
    else
        out = edu.stanford.slac.aida.client.AidaPvaClientUtils.pvaGet(channel);
    end
end
