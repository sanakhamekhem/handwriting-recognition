function appendStatus(handles, addedStatus)
    str = cellstr(get(handles.listbox2,'String'));
    rows = size(str, 1);
    str(2:rows+1) = str;
    str(1)= {addedStatus};
    set(handles.listbox2,'String', str);
end