#! /usr/bin/awk -f
#  Synopsis:    awk -f hhlib.awk awk-arg ...
#  Description: Some useful AWK functions

# Trace/Debugger functions ----------------------------------------------------------------------------------

function TRACE(msg) {
    if (0 == 1) { print "TRACE: " msg; }
}

# File/Directory functions ----------------------------------------------------------------------------------

function basename(fname,   len, indx) {  # The Unix basename utility
    for (indx = length(fname); indx > 1; --indx) {
        if (substr(fname, indx, 1) == "/")
            return substr(fname, indx)
    }
    return fname
}


function dirname(fname,   indx) {  # The Unix dirname utility
    for (indx = length(fname); indx > 1; --indx) {
        if (substr(fname, indx, 1) == "/")
            return substr(fname, 1, indx)
    }
    return "."
}

function pwd_p(dir,   pwd) {  # The "pwd -P" command
    pwd = "{ cd " dir "; pwd; }" 
    TRACE("pwd -P " dir)
    pwd | getline
    close(pwd)
    return $0
    TRACE("ret_dir = " ret_dir)
}

# String functions ------------------------------------------------------------------------------------------

function join(sep, arr, start, nelem,   retstr, indx) {  # The Python join() method.  
	retstr = arr[start, 1]                           # Example:
	for (indx = 2; indx <= nelem; ++indx)            #   s = "blah blah blah ..."      
		retstr = retstr sep arr[start+indx];     #   n = split(s, sep, arr)     
	return(retstr)                                   # ret = join(sep, arr, 1, n)
}                                                        # ret == s

# End hhlib.awk ---------------------------------------------------------------------------------------------


END  { if (DBG_HHLIB_MAIN == 1) {
           n_tst = 0;
           tst[++n_tst] = "/usr/bin/java"
           tst[++n_tst] = "/usr/local/bin/java"
           tst[++n_tst] = "java"
           #for (indx = 1; indx <= n_tst; ++indx)
           #    TRACE("dirname(" tst[indx] ") = " dirname(tst[indx]))

           for (indx = 1; indx <= n_tst; ++indx) {
               # TRACE("tst[" indx "] = " tst[indx])
               n_dirs = split(tst[indx], dirs, "/");
               # TRACE("split() = " ndirs " dirs[2] = " dirs[2])
               TRACE("join(" tst[indx] ") = " join("/", dirs, n_dirs))
           }
       }
     }

