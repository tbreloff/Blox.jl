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

  vw[6] = 555
  @fact vw[6] => 555

  # default vals at the end
  vw = view(x, y; len=10)
  for i in 1:5
    @fact vw[i] => i
  end
  for i in 7:10
    @fact vw[i] => 0
  end

  vw = view(x, x; def=1, len=10)
  @fact vw[3] => vw[7]
  @fact vw[9] => 1
  vw[1] = 33
  @fact vw[1] => 33
  @fact vw[1] => vw[5]

  # staggered blocks
  defval = 1
  vw = view(x, y; def=defval, len=12, indices=[2,8])
  @fact vw[1] => defval
  @fact vw[2] => 33
  @fact vw[6] => defval
  @fact vw[8] => 5
  @fact vw[10] => defval
  @fact_throws vw[7] = 10

end

FactCheck.exitstatus()
end