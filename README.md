# Blox

Block views without copies.  Create views from 0 to many AbstractArrays with default values, expanded lengths, and shifted positions.

Example usage for vectors:

```

julia> using Blox

julia> x = collect(1:3); y = collect(4:5);

julia> v = view(x, y)  # stacks them
5-element Blox.BlockVector{Int64}:
 1
 2
 3
 4
 5

julia> v[2] = 999
999

julia> x   # underlying vector is changed
3-element Array{Int64,1}:
   1
 999
   3

julia> v[3:4]
2-element Array{Int64,1}:
 3
 4

julia> v = view(x,y; def=-1, len=7)  # gives -1 for all indices with no array underlying
7-element Blox.BlockVector{Int64}:
   1
 999
   3
   4
   5
  -1
  -1

julia> v = view(x,y; indices=[2,7])  # starts the arrays at position 2 and 8 respectively
8-element Blox.BlockVector{Int64}:
   0
   1
 999
   3
   0
   0
   4
   5

julia> v = view(x,y; indices=[2,7], def=-999)
8-element Blox.BlockVector{Int64}:
 -999
    1
  999
    3
 -999
 -999
    4
    5
```