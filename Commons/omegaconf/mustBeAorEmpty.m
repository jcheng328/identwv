% Custom validation function to check if input is a member of a class or empty
function mustBeAorEmpty(input, className)
    if ~(isempty(input) || isa(input, className))
        error('Input must be an instance of class %s or an empty array.', className);
    end
end