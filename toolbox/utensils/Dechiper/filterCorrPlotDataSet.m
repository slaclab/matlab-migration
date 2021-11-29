function data = filterCorrPlotDataSet(data,filter)

  numDets=length(data.config.readPVNameList);
  numSteps=data.config.ctrlPVValNum;
  numSmpls=data.config.acquireSampleNum;
  
  tmp = arrayfun(@(in) in.val, data.readPV);
  newdata=NaN(size(tmp));
  subdata=zeros(size(tmp,3),1);
  newsetp=[data.ctrlPV.val];
  
  for index = 1:length(filter)
    name   = char(filter{index}{1});
    val    = filter{index}{2};
    funcstr=filter{index}{3};
    
    fprintf('channel PV: %s\nlimit: %e\nfilter function: %s\n',name,val,funcstr)
    
    idx = strmatch(filter{index}{1},data.config.readPVNameList);
    tmpfunc=eval(funcstr);
    
    for n=1:size(tmp,2)
      subdata(:)=tmp(idx,n,:);
      indx=tmpfunc(subdata,val);
      numValidPoints=sum(indx);
      if numValidPoints > 0
        newdata(:,n,1:numValidPoints)=tmp(:,n,indx);
      else
        newsetp(n)=[];
      end
      
    end
    
  end

  for n=1:numDets
    for m=1:numSteps
      for k=1:numSmpls
        data.readPV(n,m,k).val=newdata(n,m,k);
      end
    end
  end
end


