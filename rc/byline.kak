provide-module byline %{

# Mappings

map global "normal" "x" ": byline-drag-down<ret>"
map global "normal" "X" ": byline-drag-up<ret>"

# High-level selection expanding and contracting, based on selection direction

define-command -hidden byline-drag-down -params 0..1 %{
  evaluate-commands -itersel -no-hooks %{
    try %{
      byline-assert-selection-multi-line
    } catch %{
      execute-keys "<a-:>"
    }

    try %{
      byline-assert-selection-forwards
      byline-expand-below
    } catch %{
      byline-contract-above
    }
  }
}

define-command -hidden byline-drag-up -params 0..1 %{
  evaluate-commands -itersel -no-hooks %{
    try %{
      byline-assert-selection-multi-line
    } catch %{
      execute-keys "<a-:><a-;>"
    }

    try %{
      byline-assert-selection-reduced
      byline-expand-above
    } catch %{
      try %{
        byline-assert-selection-really-reduced-blank-line
        byline-expand-above
      } catch %{
        try %{
          byline-assert-selection-forwards
          byline-contract-below
        } catch %{
          byline-expand-above
        }
      }
    }
  }
}

# Assertions

define-command -hidden byline-assert-selection-forwards %{
  try %{
    # If the selection is just the cursor, we treat it as being in the forwards
    # direction, and can exit early
    byline-assert-selection-reduced
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

define-command -hidden byline-assert-selection-multi-line %{
  evaluate-commands -no-hooks %sh{
    anchor_row=$(echo "$kak_selection_desc" | cut -d "," -f 1 | cut -d "." -f 1)
    cursor_row=$(echo "$kak_selection_desc" | cut -d "," -f 2 | cut -d "." -f 1)
    [ "$cursor_row" = "$anchor_row" ] && echo "fail"
  }
}

define-command -hidden byline-assert-selection-reduced %{
  # Selections on blank lines are not considered reduced
  execute-keys -draft "<a-K>^$<ret>"
  # Single-character selections are reduced
  execute-keys -draft "<a-k>\A.{,1}\z<ret>"
}

define-command -hidden byline-assert-selection-not-reduced %{
  try %{
    # Selections on blank lines are not considered reduced
    execute-keys -draft "<a-k>^$<ret>"
  } catch %{
    # If a selection is 2+ characters long, it isn't reduced
    execute-keys -draft "<a-k>.{2,}<ret>"
  }
}

define-command -hidden byline-assert-selection-really-reduced-blank-line %{
  execute-keys -draft "<a-k>^$<ret>"
  execute-keys -draft "<a-k>\A.{,1}\z<ret>"
}

define-command -hidden byline-assert-cursor-beginning-of-line %{
  execute-keys -draft ";<a-k>^<ret>"
}

define-command -hidden byline-assert-cursor-end-of-line %{
  execute-keys -draft ";<a-k>$<ret>"
}

define-command -hidden byline-assert-cursor-not-end-of-line %{
  execute-keys -draft ";<a-K>$<ret>"
}

define-command -hidden byline-assert-no-count %{
  execute-keys -draft "<space>;%val{count}s.<ret>"
}

# Low-level selection expanding and contracting primitives

define-command -hidden byline-expand-to-beginning-of-line %{
  try %{
    byline-assert-cursor-beginning-of-line
  } catch %{
    execute-keys "<a-:><a-;>"
    execute-keys "Gh"
  }
}

define-command -hidden byline-expand-to-end-of-line %{
  try %{
    byline-assert-cursor-end-of-line
  } catch %{
    execute-keys "<a-:>"
    execute-keys "GlL"
  }
}

define-command -hidden byline-expand-above -params 0..1 %{
  execute-keys "<a-:><a-;>"
  try %{
    byline-assert-selection-not-reduced
    byline-assert-cursor-beginning-of-line
    execute-keys "%val{count}K"
  } catch %{
    byline-expand-to-end-of-line
    execute-keys "%val{count}K"
    try %{
      byline-assert-no-count
    } catch %{
      execute-keys "K"
    }
    execute-keys "J"
  }
  byline-expand-to-beginning-of-line
}

define-command -hidden byline-contract-above -params 0..1 %{
  execute-keys "<a-:><a-;>"
  execute-keys "%val{count}J"
  byline-expand-to-beginning-of-line
}

define-command -hidden byline-expand-below -params 0..1 %{
  execute-keys "<a-:>"
  try %{
    byline-assert-selection-reduced
    execute-keys "%val{count}X"
    try %{
      byline-assert-no-count
    } catch %{
      execute-keys "X"
    }
  } catch %{
    try %{
      byline-assert-cursor-end-of-line
    } catch %{
      byline-expand-to-beginning-of-line
      execute-keys "K"
    }
    execute-keys "%val{count}J"
    byline-expand-to-end-of-line
  }
}

define-command -hidden byline-contract-below -params 0..1 %{
  execute-keys "<a-:>"
  execute-keys "%val{count}K"
  byline-expand-to-end-of-line
}

}
