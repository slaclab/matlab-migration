function slcDbSetDemo(query, value)

  % slcDbSetDemo(query, value)
  %
  % Usage example:
  %   slcDbSetDemo('XCOR:LI31:41//BCON', 5.0);
  %
  % Aida SLC Database Set demonstration function.  This function
  % sets the value of a SLC Database float scalar secondary.
  %
  % query - string consisting of a Aida instance name (e.g.,
  % primary:micro:unit), double slashes, and the Aida attribute
  % name (a SLC database secondary name).
  %
  % value - new float value.
  %

% AIDA-PVA imports
global pvaSet;

pvaSet(query, value);

return;
