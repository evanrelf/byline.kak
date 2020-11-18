map global "normal" "x" ": drag-down %%val{count}<ret>"
map global "normal" "X" ": drag-up %%val{count}<ret>"

define-command -hidden drag-down -params 1 %{ evaluate-commands -itersel %{
  # When selection isn't multi-line, make the selection point forwards
  try %{
    assert-selection-multi-line
  } catch %{
    execute-keys "<a-:>"
  }

  try %{
    assert-selection-forwards
    try %{
      assert-cursor-end-of-line
      assert-selection-not-reduced
      grow-below "%arg{1}"
    } catch %{
      # Otherwise, we need to make the initial line selection
      execute-keys "<a-x>"
    }
  } catch %{
    try %{
      assert-cursor-beginning-of-line
      assert-selection-not-reduced
      shrink-above "%arg{1}"
    } catch %{
      # Otherwise, we need to make the initial line selection
      execute-keys "<a-x><a-;>"
    }
  }
}}

define-command -hidden drag-up -params 1 %{ evaluate-commands -itersel %{
  try %{
    assert-selection-forwards
    assert-selection-multi-line
    shrink-below "%arg{1}"
  } catch %{
    grow-above "%arg{1}"
  }
}}

define-command -hidden assert-selection-forwards %{
  try %{
    # If the selection is just the cursor, we treat it as being in the forwards
    # direction, and can exit early
    assert-selection-reduced
  } catch %{ evaluate-commands %sh{
    # Otherwise, we need to inspect the selection
    cursor_row=$(echo "$kak_selection_desc" | cut -d , -f 2 | cut -d . -f 1)
    anchor_row=$(echo "$kak_selection_desc" | cut -d , -f 1 | cut -d . -f 1)
    cursor_col=$(echo "$kak_selection_desc" | cut -d , -f 2 | cut -d . -f 2)
    anchor_col=$(echo "$kak_selection_desc" | cut -d , -f 1 | cut -d . -f 2)
    # If the cursor is behind the anchor, the selection isn't in the forwards
    # direction
    [ $((cursor_col <= anchor_col)) = "1" -a $((cursor_row <= anchor_row)) = "1" ] && echo "fail"
  }}
}

define-command -hidden assert-selection-multi-line %{ evaluate-commands %sh{
  cursor_row=$(echo "$kak_selection_desc" | cut -d , -f 2 | cut -d . -f 1)
  anchor_row=$(echo "$kak_selection_desc" | cut -d , -f 1 | cut -d . -f 1)
  # If the cursor and anchor are on the same row, this isn't a multi-line
  # selection
  [ "$cursor_row" = "$anchor_row" ] && echo "fail"
}}

define-command -hidden assert-selection-reduced %{
  # Selections on blank lines are not considered reduced
  execute-keys -draft "<a-K>^$<ret>"
  # If a selection is 1 character long, it is reduced
  execute-keys -draft "<a-k>\A.{,1}\z<ret>"
}

define-command -hidden assert-selection-not-reduced %{
  try %{
    # Selections on blank lines are not considered reduced
    execute-keys -draft "<a-k>^$<ret>"
  } catch %{
    # If a selection is 2+ characters long, it isn't reduced
    execute-keys -draft "<a-k>.{2,}<ret>"
  }
}

define-command -hidden assert-cursor-beginning-of-line %{
  execute-keys -draft ";<a-k>^<ret>"
}

define-command -hidden assert-cursor-end-of-line %{
  execute-keys -draft ";<a-k>$<ret>"
}

define-command -hidden assert-cursor-not-end-of-line %{
  execute-keys -draft ";<a-K>$<ret>"
}

define-command -hidden grow-to-end-of-line %{
  execute-keys "Gl"
  try %{
    assert-cursor-not-end-of-line
    execute-keys "L"
  }
}

define-command -hidden grow-above -params 1 %{
  execute-keys "<a-:><a-;>Gh%arg{1}K"
}

define-command -hidden shrink-above -params 1 %{
  execute-keys "<a-:><a-;>Gh%arg{1}J"
}

define-command -hidden grow-below -params 1 %{
  execute-keys "<a-:>%arg{1}J"
  grow-to-end-of-line
}

define-command -hidden shrink-below -params 1 %{
  execute-keys "<a-:>%arg{1}K"
  grow-to-end-of-line
}
