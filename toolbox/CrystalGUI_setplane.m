function CrystalGUI_setplane(data,where,mamma)

nonno=get(mamma,'parent');
stringa=['[',num2str(data),']'];
Pointers=get(nonno,'UserData');
set(Pointers(where,1),'String',stringa);
set(Pointers(where,2),'Value',1);    


