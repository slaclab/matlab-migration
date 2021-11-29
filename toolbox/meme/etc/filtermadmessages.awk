# Search MAD echo files for MAD error messages. 
# If any are found, print them and set to exit with non-0 error code.
# 
# ------------------------------------------------------------------
# Auth: Greg White, 24-Jun-2014, SLAC.
# Mod: 
# ==================================================================
BEGIN { errors = 0; warnings = 0; msg=""}
/## Warning ##/,/^[ ]*$/ { print; warnings = 1; }
/\*\*\* Error \*\*\*/,/^[ ]*$/ { print; errors = 1; }
END { 
      if (errors == 1) 
         exit 1;
      else if ( warnings == 1)
         exit 2;
      else
         exit 0;
}
