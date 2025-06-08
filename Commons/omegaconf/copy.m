% Copy function - replacement for matlab.mixin.Copyable.copy() to create object copies
function newObj = copy(obj)
    %{
    obj1 = ... % anything really!
    obj2 = obj1.copy();  % alternative #1
    obj2 = copy(obj1);   % alternative #2 ** preferable, for more data type e.g., [] or  abcf or magic(5) or a struct or cell array
    %}
    try
        % R2010b or newer - directly in memory (faster)
        objByteArray = getByteStreamFromArray(obj);
        newObj = getArrayFromByteStream(objByteArray);
    catch
        % R2010a or earlier - serialize via temp file (slower)
        fname = [tempname '.mat'];
        save(fname, 'obj');
        newObj = load(fname);
        newObj = newObj.obj;
        delete(fname);
    end
end