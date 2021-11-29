function imgProcessing_panel_updateAlgPopupmenu(ipHandles, algNames)
if ~isempty(algNames)
    val = get(ipHandles.algPopupmenu, 'value');
    if val > size(algNames, 2)
        set(ipHandles.algPopupmenu, 'value', 1);
    end
    set(ipHandles.algPopupmenu, 'enable', 'on', 'string', algNames);
else
    set(ipHandles.algPopupmenu, 'enable', 'off', 'string', 'N/A', 'value', 1);
end
