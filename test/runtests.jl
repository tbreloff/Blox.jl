module BlockTests

using Blox
using FactCheck

@fact 1 => 1

x = collect(1:4)
y = collect(5:6)
vw = view(x, y)
@fact length(vw) => length(x) + length(y)

for i in 1:6
  @fact vw[i] => i
end

FactCheck.exitstatus()
end