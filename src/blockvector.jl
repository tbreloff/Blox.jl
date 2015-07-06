

immutable Block1{T}
  vec::AbstractVector{T}
  startidx::Int
end
block{T<:Number}(vec::AbstractVector{T}, startidx::Int) = Block1{T}(vec, startidx)

startidx(block::Block1) = block.startidx
endidx(block::Block1) = block.startidx + length(block.vec) - 1

# --------------------------------------------------------------------------------------------------

# you can create a sparse representation of blocked vectors with default val in the empty spaces
# example: this is a nice way to create the input vector to a regression that has a bias term: "v = view(length(x)+1, x)"
type BlockVector{T} <: AbstractVector{T}
  blocks::Vector{Block1{T}}
  defaultval::T
  len::Int
end

# function ArrayViews.view{T<:Number}(vs::AbstractVector{T}...; def::T = zero(T), len::Int = 0)
#   blocks = Array(Block1{T}, length(vs))
#   totlen = 0
#   for (i,v) in enumerate(vs)
#     blocks[i] = block(v, totlen + 1)
#     totlen += length(v)
#   end
#   BlockVector{T}(blocks, def, max(totlen, len))
# end

# # ArrayViews.view{T<:Number}(len::Int, vs::AbstractVector{T}...) = view(zero(T), len, vs...)
# # ArrayViews.view{T<:Number}(vs::AbstractVector{T}...) = view(zero(T), 0, vs...)

# --------------------------------------------------------------------------------------------------

function computeStartIndices{T}(vs::AbstractVector{T}...)
  indices = Array(Int, length(vs))
  totlen = 0
  for (i,v) in enumerate(vs)
    indices[i] = totlen + 1
    totlen += length(v)
  end
  indices
end

# methods to create the BlockVector with a list of start indices

# function ArrayViews.view{T<:Number}(indices::AbstractVector{Int}, vs::AbstractVector{T}...; def::T = zero(T), len::Int = 0)
# function ArrayViews.view{T<:Number}(vpairs::Pair{Int,AbstractVector{T}}...; def::T = zero(T), len::Int = 0)
function ArrayViews.view{T<:Number}(vs::AbstractVector{T}...; def::T = zero(T), len::Int = 0, indices::AbstractVector{Int} = computeStartIndices(vs...))
  @assert length(vs) == length(indices)
  blocks = Array(Block1{T}, length(vs))
  totlen = 0
  for (i,v) in enumerate(vs)
    startidx = indices[i]
    @assert startidx > totlen
    blocks[i] = block(v, startidx)
    totlen = startidx + length(v) - 1
  end
  BlockVector{T}(blocks, def, max(totlen, len))
end

# ArrayViews.view{T<:Number}(len::Int, indices::AbstractVector{Int}, vs::AbstractVector{T}...) = view(zero(T), indices, len, vs...)
# ArrayViews.view{T<:Number}(indices::AbstractVector{Int}, vs::AbstractVector{T}...) = view(zero(T), indices, 0, vs...)


# --------------------------------------------------------------------------------------------------

function Base.getindex(blockvec::BlockVector, i::Int)
  checkbounds(blockvec, i)
  for block in blockvec.blocks
    sidx = startidx(block)
    i < sidx && break
    i < sidx + length(block.vec) && return block.vec[i - sidx + 1]
  end
  return blockvec.defaultval
end

setindex_error() = error("You're calling BlockVector::setindex for an index without an underlying array... not currently allowed")

function Base.setindex!{T<:Number}(blockvec::BlockVector{T}, data::T, i::Int)
  checkbounds(blockvec, i)
  for block in blockvec.blocks
    sidx = startidx(block)
    i < sidx && setindex_error()
    if i < sidx + length(block.vec)
      block.vec[i - sidx + 1] = data
      return
    end
  end
  setindex_error()
end

Base.length(blockvec::BlockVector) = blockvec.len
Base.size(blockvec::BlockVector) = (length(blockvec),)

# --------------------------------------------------------------------------------------------------


