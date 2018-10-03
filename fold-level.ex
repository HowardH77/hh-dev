# " Description: vim fold all line where indent level is greater than the level at the cursor position

" 1. indent_level = Get current level at cursor position;
     save-current_line
" 2. For every line
"       if line.indent_level > indent_level
"           ++indent_lines
"       else if (indent_lines > 0) 
"           zf-(indent_lines)  # Create fold (move cursor to current line, zf<cursor-motion = up $indent_lines)
"           indent_lines=0
" 3.  Restore cursor to save_current_line
