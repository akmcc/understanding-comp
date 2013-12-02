#overriding #inspect works in irb, but not in pry due to, what I imagine is, a custom inspect method that pry uses

module Simple_Kernel
  def inspect
    "<<#{self}>>"
  end
end