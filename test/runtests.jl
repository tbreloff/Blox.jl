module BlockTests

using Blox
using FactCheck

facts("Blox") do
  @fact 1 => 1

  x = collect(1:4)
  y = collect(5:6)
  vw = view(x, y)
  @fact length(vw) => length(x) + length(y)
  @fact size(vw) => (length(vw),)

  for i in 1:6
    @fact vw[i] => i
  end
  @fact_throws vw[0]
  @fact_throws vw[7]

  # default vals at the end
  vw = view(10, x, y)
  for i in 1:6
    @fact vw[i] => i
  end
  for i in 7:10
    @fact vw[i] => 0
  end

end

FactCheck.exitstatus()
end