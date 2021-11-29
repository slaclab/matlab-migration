function OUT=OnToOneConversion(IN)

if(isnumeric(IN))
   if(IN)
       OUT='on';
   else
       OUT='off';
   end
else
    if(strcmpi(IN,'on'))
        OUT=1;
    else
        OUT=0;
    end
end