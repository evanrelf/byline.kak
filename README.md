# expand-line.kak

Expand and shrink line-based selections with `x` and `X`.

TL;DR: `x` drags the cursor down, `X` drags the cursor up. See the "Examples"
section below for a more detailed explanation.

## Installation

### Using [plug.kak](https://github.com/robertmeta/plug.kak) (recommended)

With plug.kak installed, add to your `kakrc` file:

```kakoune
plug "evanrelf/expand-line.kak"
```

### Manually

Download plugin:

```bash
$ mkdir -p ~/.config/kak/plugins/
$ curl -L https://raw.githubusercontent.com/evanrelf/expand-line.kak/main/rc/expand-line.kak -o ~/.config/kak/plugins/expand-line.kak
```

Add to your `kakrc` file:

```kakoune
source ~/.config/kak/plugins/expand-line.kak
```

## Usage

Use `x` and `X` to drag the cursor down and up by lines, respectively. This
expands or contracts your selection by lines, based on the direction of your
selection.

## Examples

#### Press <kbd>x</kbd> to drag the cursor (`|`) down

<table>

<tr>
<th>&nbsp;</th>
<th>&bull; Initial selection</th>
<th>&rarr; Pressed <kbd>x</kbd></th>
<th>&rarr; Pressed <kbd>x</kbd></th>
</tr>

<tr>

<td>Expand downwards</td>

<td>

```
[T|he quick brown
fox jumps over
the lazy dog
```

</td>

<td>

```
[The quick brown|
fox jumps over
the lazy dog
```

</td>

<td>

```
[The quick brown
fox jumps over|
the lazy dog
```

</td>

</tr>
</table>

<table>

<tr>
<th>&nbsp;</th>
<th>&bull; Initial selection</th>
<th>&rarr; Pressed <kbd>x</kbd></th>
<th>&rarr; Pressed <kbd>x</kbd></th>
</tr>

<tr>

<td>Contract downwards</td>

<td>

```
|The quick brown
fox jumps over
the lazy dog]
```

</td>

<td>

```
The quick brown
|fox jumps over
the lazy dog]
```

</td>

<td>

```
The quick brown
fox jumps over
|the lazy dog]
```

</td>

</tr>
</table>


#### Press <kbd><a-;></kbd> to swap the cursor (`|`) with the anchor (`[` or `]`)

<table>

<tr>
<th>&bull; Initial selection</th>
<th>&rarr; Pressed <kbd>&lt;a-;&gt;</kbd></th>
<th>&rarr; Pressed <kbd>&lt;a-;&gt;</kbd></th>
</tr>

<tr>

<td>

```
[The quick brown|
fox jumps over
the lazy dog
```

</td>

<td>

```
|The quick brown]
fox jumps over
the lazy dog
```

</td>

<td>

```
[The quick brown|
fox jumps over
the lazy dog
```

</td>

</tr>
</table>

#### Press <kbd>X</kbd> to drag the cursor (`|`) up

<table>

<tr>
<th>&nbsp;</th>
<th>&bull; Initial selection</th>
<th>&rarr; Pressed <kbd>X</kbd></th>
<th>&rarr; Pressed <kbd>X</kbd></th>
</tr>

<tr>

<td>Expand upwards</td>

<td>

```
The quick brown
fox jumps over
|the lazy dog]
```

</td>

<td>

```
The quick brown
|fox jumps over
the lazy dog]
```

</td>

<td>

```
|The quick brown
fox jumps over
the lazy dog]
```

</td>

</tr>
</table>

<table>

<tr>
<th>&nbsp;</th>
<th>&bull; Initial selection</th>
<th>&rarr; Pressed <kbd>X</kbd></th>
<th>&rarr; Pressed <kbd>X</kbd></th>
</tr>

<tr>

<td>Contract upwards</td>

<td>

```
[The quick brown
fox jumps over
the lazy dog|
```

</td>

<td>

```
[The quick brown
fox jumps over|
the lazy dog
```

</td>

<td>

```
[The quick brown|
fox jumps over
the lazy dog
```

</td>

</tr>
</table>
