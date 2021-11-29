function madPatchFile(K,N,P,twssi,Ei,madPFile)
%
% Create a MAD patch-file containing run data from XAL

% ------------------------------------------------------------------------------
% 15-JAN-2009, M. Woodley
%    Add support for undulators (keyw=UNDU); magnets split into 4 pieces; strip
%    extra character from TCAV names
% 13-DEC-2008, M. Woodley
%    Strip ':RG' from LCAV element names
% ------------------------------------------------------------------------------

keyw=['LCAV';'SBEN';'QUAD';'SOLE';'UNDU'];
[Nkeyw,dummy]=size(keyw);
twopi=2*pi;

fid=fopen(madPFile,'w');

fprintf(fid,'BEAM, ENERGY=%s\n',madval(Ei));
fprintf(fid,'SET, TWSSC[ENERGY], %s\n',madval(Ei));
fprintf(fid,'SET, TWSSC[MUX], %s\n',madval(twssi(1)/twopi));
fprintf(fid,'SET, TWSSC[BETX], %s\n',madval(twssi(2)));
fprintf(fid,'SET, TWSSC[ALFX], %s\n',madval(twssi(3)));
fprintf(fid,'SET, TWSSC[DX], %s\n',madval(twssi(4)));
fprintf(fid,'SET, TWSSC[DPX], %s\n',madval(twssi(5)));
fprintf(fid,'SET, TWSSC[MUY], %s\n',madval(twssi(6)/twopi));
fprintf(fid,'SET, TWSSC[BETY], %s\n',madval(twssi(7)));
fprintf(fid,'SET, TWSSC[ALFY], %s\n',madval(twssi(8)));
fprintf(fid,'SET, TWSSC[DY], %s\n',madval(twssi(9)));
fprintf(fid,'SET, TWSSC[DPY], %s\n',madval(twssi(10)));

skip=0;
for k=1:Nkeyw
  id=strmatch(keyw(k,:),K);
  for m=1:length(id)
    n=id(m);
    name=deblank(N(n,:));
    if (strcmp(keyw(k,:),'LCAV'))
      name=strrep(name,':RG',''); % strip ':RG' from LCAV names
    else
      name=strrep(name,'x',''); % strip 'x' from names
      name=strrep(name,'y',''); % strip 'y' from names
    end
    tcav=strcmp('TCAV',name(1:min(length(name),4)));
    if (tcav)
      name=name(1:end-1);
    end
    switch keyw(k,:)
      case 'LCAV'
        if (tcav&&skip)
          skip=0;
        else
          fprintf(fid,'SET, %s[DELTAE], %s\n',name,madval(P(n,6)));
          fprintf(fid,'SET, %s[PHI0], %s\n',name,madval(P(n,7)));
          fprintf(fid,'SET, %s[ELOSS], %s\n',name,madval(P(n,8)));
          skip=tcav;
        end
      case 'SBEN'
        % assume nominal bending
      case 'QUAD'
        if (skip)
          skip=skip+1;
          if (skip==4),skip=0;end
        else
          fprintf(fid,'SET, %s[K1], %s\n',name,madval(P(n,2)));
          skip=1;
        end
      case 'SOLE'
        if (skip)
          skip=skip+1;
          if (skip==4),skip=0;end
        else
          fprintf(fid,'SET, %s[KS], %s\n',name,madval(P(n,5)));
          skip=1;
        end
      case 'UNDU'
        if (strfind(name,'LH_UND'))
          if (skip)
            skip=skip+1;
            if (skip==4),skip=0;end
          else
            K_und=P(n,1);
            if (K_und==0),K_und=1e-12;end
            fprintf(fid,'SET, K_und, %s\n',madval(K_und));
            fprintf(fid,'SET, lam, %s\n',madval(P(n,2)));
            skip=1;
          end
        else
          if (~skip)
            Kund=P(n,1);
            if (Kund==0),Kund=1e-12;end
            fprintf(fid,'SET, Kund, %s\n',madval(Kund));
            fprintf(fid,'SET, lamu, %s\n',madval(P(n,2)));
            skip=1;
          end
        end
    end
  end
end
fprintf(fid,'RETURN\n');

fclose(fid);

end
