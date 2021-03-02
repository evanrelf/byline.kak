# Mappings

map global "normal" "x" ": expand-line-drag-down<ret>"
map global "normal" "X" ": expand-line-drag-up<ret>"

# High-level selection expanding and contracting, based on selection direction

define-command -hidden expand-line-drag-down -params 0..1 %{
  evaluate-commands -itersel -no-hooks %{
    try %{
      expand-line-assert-selection-multi-line
    } catch %{
      execute-keys "<a-:>"
    }

    try %{
      expand-line-assert-selection-forwards
      expand-line-expand-below
    } catch %{
      expand-line-contract-above
    }
  }
}

define-command -hidden expand-line-drag-up -params 0..1 %{
  evaluate-commands -itersel -no-hooks %{
    try %{
      expand-line-assert-selection-multi-line
    } catch %{
      execute-keys "<a-:><a-;>"
    }

    try %{
      expand-line-assert-selection-reduced
      expand-line-expand-above
    } catch %{
      try %{
        expand-line-assert-selection-really-reduced-blank-line
        expand-line-expand-above
      } catch %{
        try %{
          expand-line-assert-selection-forwards
          expand-line-contract-below
        } catch %{
          expand-line-expand-above
        }
      }
    }
  }
}

# Assertions

define-command -hidden expand-line-assert-selection-forwards %{
  try %{
    # If the selection is just the cursor, we treat it as being in the forwards
    # direction, and can exit early
    expand-line-assert-selection-reduced
  } catch %{
    evaluate-commands -no-hooks %sh{
      # Otherwise, we need to inspect the selection
      cursor_row=$(echo "$kak_selection_desc" | cut -d "," -f 2 | cut -d "." -f 1)
      anchor_row=$(echo "$kak_selection_desc" | cut -d "," -f 1 | cut -d "." -f 1)
      [ $((cursor_row > anchor_row)) = "1" ] && exit
      [ $((cursor_row < anchor_row)) = "1" ] && (echo "fail"; exit)
      anchor_col=$(echo "$kak_selection_desc" | cut -d "," -f 1 | cut -d "." -f 2)
      cursor_col=$(echo "$kak_selection_desc" | cut -d "," -f 2 | cut -d "." -f 2)
      [ $((cursor_col < anchor_col)) = "1" ] && (echo "fail"; exit)
    }
  }
}

define-command -hidden expand-line-assert-selection-multi-line %{
  evaluate-commands -no-hooks %sh{
    anchor_row=$(echo "$kak_selection_desc" | cut -d "," -f 1 | cut -d "." -f 1)
    cursor_row=$(echo "$kak_selection_desc" | cut -d "," -f 2 | cut -d "." -f 1)
    [ "$cursor_row" = "$anchor_row" ] && echo "fail"
  }
}

define-command -hidden expand-line-assert-selection-reduced %{
  # Selections on blank lines are not considered reduced
  execute-keys -draft "<a-K>^$<ret>"
  # Single-character selections are reduced
  execute-keys -draft "<a-k>\A.{,1}\z<ret>"
}

define-command -hidden expand-line-assert-selection-not-reduced %{
  try %{
    # Selections on blank lines are not considered reduced
    execute-keys -draft "<a-k>^$<ret>"
  } catch %{
    # If a selection is 2+ characters long, it isn't reduced
    execute-keys -draft "<a-k>.{2,}<ret>"
  }
}

define-command -hidden expand-line-assert-selection-really-reduced-blank-line %{
  execute-keys -draft "<a-k>^$<ret>"
  execute-keys -draft "<a-k>\A.{,1}\z<ret>"
}

define-command -hidden expand-line-assert-cursor-beginning-of-line %{
  execute-keys -draft ";<a-k>^<ret>"
}

define-command -hidden expand-line-assert-cursor-end-of-line %{
  execute-keys -draft ";<a-k>$<ret>"
}

define-command -hidden expand-line-assert-cursor-not-end-of-line %{
  execute-keys -draft ";<a-K>$<ret>"
}

define-command -hidden expand-line-assert-no-count %{
  execute-keys -draft "<space>;%val{count}s.<ret>"
}

# Low-level selection expanding and contracting primitives

define-command -hidden expand-line-expand-to-beginning-of-line %{
  try %{
    expand-line-assert-cursor-beginning-of-line
  } catch %{
    execute-keys "<a-:><a-;>"
    execute-keys "Gh"
  }
}

define-command -hidden expand-line-expand-to-end-of-line %{
  try %{
    expand-line-assert-cursor-end-of-line
  } catch %{
    execute-keys "<a-:>"
    execute-keys "GlL"
  }
}

define-command -hidden expand-line-expand-above -params 0..1 %{
  execute-keys "<a-:><a-;>"
  try %{
    expand-line-assert-selection-not-reduced
    expand-line-assert-cursor-beginning-of-line
    execute-keys "%val{count}K"
  } catch %{
    expand-line-expand-to-end-of-line
    execute-keys "%val{count}K"
    try %{
      expand-line-assert-no-count
    } catch %{
      execute-keys "K"
    }
    execute-keys "J"
  }
  expand-line-expand-to-beginning-of-line
}

define-command -hidden expand-line-contract-above -params 0..1 %{
  execute-keys "<a-:><a-;>"
  execute-keys "%val{count}J"
  expand-line-expand-to-beginning-of-line
}

define-command -hidden expand-line-expand-below -params 0..1 %{
  execute-keys "<a-:>"
  try %{
    expand-line-assert-selection-reduced
    execute-keys "%val{count}X"
    try %{
      expand-line-assert-no-count
    } catch %{
      execute-keys "X"
    }
  } catch %{
    try %{
      expand-line-assert-cursor-end-of-line
    } catch %{
      expand-line-expand-to-beginning-of-line
      execute-keys "K"
    }
    execute-keys "%val{count}J"
    expand-line-expand-to-end-of-line
  }
}

define-command -hidden expand-line-contract-below -params 0..1 %{
  execute-keys "<a-:>"
  execute-keys "%val{count}K"
  expand-line-expand-to-end-of-line
}
