function out = pvaGet(channel, varargin)
    if ( length(varargin) > 0 )
        out = ML(edu.stanford.slac.aida.client.AidaPvaClientUtils.pvaGet(channel, varargin{1}));
    else
        out = ML(edu.stanford.slac.aida.client.AidaPvaClientUtils.pvaGet(channel));
    end
end
